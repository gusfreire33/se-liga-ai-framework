---
name: sl-parallel-dispatch
description: "Use when executing a plan/feature across many subagents — decompose into atomic tasks, order them into parallel waves via DAG, route each task to the cheapest sufficient model (Worker/Haiku/Sonnet/Opus), and verify outputs. Powers sl.build and sl-subagent-driven-development with parallelism, model routing and the CODE > LLM principle."
---

# Parallel Dispatch (DAG Waves + Model Routing + CODE > LLM)

Despachar trabalho em série, tudo no modelo mais caro, é desperdício. Esta skill traz o motor
de execução paralela: **decompor → ordenar em waves (DAG) → rotear modelo → executar em
subagentes → verificar**. Filosofia central: **CODE > LLM** (script determinístico pra contar,
parsear e validar; LLM só pra raciocínio). Complementa `sl-subagent-driven-development` (que
cobre o loop de review entre tasks) e é o motor por trás de `/sl.dispatch`.

## When to Use

- Executar um `plan.md` / feature com várias tasks que podem rodar em paralelo
- Build grande onde rodar tudo no modelo principal é lento e caro
- Sempre que houver trabalho mecânico repetível misturado com trabalho que exige julgamento

## When NOT to Use

- Task única e linear (despachar overhead > ganho)
- Trabalho puramente arquitetural/estratégico — isso não se despacha, se decide (`/sl.plan`)

## O pipeline (7 fases)

```
Fase 0  SUFFICIENCY GATE   input bem-definido? (vetos V0 — ver sl-veto-conditions)
Fase 1  DECOMPOSE          story → tasks atômicas (1 task = 1 entregável)
Fase 2  ROUTE              cada task → executor + modelo + nível de contexto
Fase 3  WAVE PLAN          DAG → topological sort → waves paralelas
Fase 4  PRE-EXEC GATE      vetos V1 (placeholder, sem output, ciclo, sem modelo)
Fase 5  EXECUTE            subagentes em paralelo, por wave
Fase 6  POST-EXEC GATE     vetos V2 + relatório (custo, falhas, waves)
```

## 1. Decompose — task atômica

Uma task só é despachável se:
- tem **1 entregável** e um **output path** explícito;
- tem **critério de aceite mensurável** (não "ficar bom" — ver veto V1.2);
- não tem placeholder/verbo vago.

Tasks que falham aqui voltam pro planejamento, não pro despacho.

## 2. Route — qual executor e modelo (CODE > LLM)

Árvore de decisão (do mais barato pro mais caro — **sempre desça o mínimo necessário**):

```
Q1  É 100% determinístico? (mkdir, mv, preencher template, contar, parsear)
      ├─ Existe lib/tool pronto (jq, git, sed, yaml)?  → WORKER (script)  $0
      └─ Vai rodar 3+ vezes / semanalmente?            → WORKER (codifica)
         senão                                          → HAIKU (one-off)
Q2  Tem template explícito + critério claro?           → HAIKU      ~$0.007/task
Q3  Exige julgamento / avaliação / análise?            → SONNET     ~$0.025/task
Q4  É arquitetural / estratégico / ambíguo?            → NÃO despache → /sl.plan
```

Restrições do Haiku (senão vira veto V1.5/V1.6):
- instruções em **inglês**, output no idioma alvo declarado à parte (sem code-switching);
- **template obrigatório** pra outputs > 50 linhas;
- "DO NOT ask questions. Execute immediately." no prompt;
- 1 task = 1 entregável.

Orquestração: o **orquestrador não raciocina** — ele segue `next_action` de scripts. Haiku basta.
Regra: *"Haiku + scripts bem-feitos > Opus sozinho."* Se a orquestração precisa de Opus, o script
está quebrado — conserte o script.

### Fallback / escalonamento

| Modelo | falha/qualidade<thr/timeout → | retries antes de escalar |
|--------|------|------|
| Haiku  | → Sonnet (qual < 0.70) | 2 |
| Sonnet | → Opus (qual < 0.60) | 1 |
| Opus   | → humano | 1 |

Circuit breaker: **3 escalonamentos consecutivos → HALT a wave**. Isso é problema de prompt, não de modelo.

## 3. Wave Plan — DAG e paralelismo

Tasks com dependências formam um grafo. Use **topological sort (Kahn)** pra agrupar em waves:
tudo numa wave roda em paralelo; a wave N+1 só começa quando N termina.

```
Task A (sem deps) ─┐
Task B (sem deps) ─┤→ Wave 1 (paralelo)
Task C dep[A]     ─┐
Task D dep[A,B]   ─┤→ Wave 2
Task E dep[C,D]    →  Wave 3
```

- **Detecte ciclos primeiro** — ciclo = veto V1.4 (hard_block). Sem grafo acíclico, sem despacho.
- Limite prático: ~5–7 tasks por wave (rate limits + foco).
- Runtime helper: `.codesl/scripts/wave-optimizer.sh` recebe um arquivo `task<TAB>deps,csv`
  e emite as waves (ou falha com exit 1 se houver ciclo). Use-o como o `check` do veto V1.4.

## 4–6. Gates + Execução + Relatório

- **Pre-exec (V1):** rode os vetos sobre cada task (ver `sl-veto-conditions`). Bloqueia o que
  está malformado ANTES de gastar tokens.
- **Execute:** uma chamada de subagente por task da wave, **em paralelo** (no Claude Code:
  múltiplos `Agent`/Task numa única mensagem). Cada subagente recebe contexto mínimo necessário
  (MINIMAL/STANDARD/FULL) — não despeje o repo inteiro.
- **Post-exec (V2):** arquivo existe? não-vazio? sem placeholder? Custo dentro do esperado?
  Falhou → retry (máx 2) → escala. Feche com relatório: waves, tasks, modelo usado, custo, falhas.

## Por que isso importa (custo)

Rodar orquestração + tasks mecânicas no modelo top custa ordens de magnitude a mais. Roteando
worker/Haiku o que é mecânico e reservando Sonnet/Opus pro que exige julgamento, o mesmo trabalho
sai **dezenas de vezes mais barato** — com o ganho extra de paralelismo nas waves.

## Caching de prompt

Prefixo **estático** (KB, regras, system) + sufixo **dinâmico** (a task). Em waves do mesmo domínio,
o prefixo é cacheado e o input fica ~75% mais barato. Monte os prompts nessa ordem.

## Integração no SL

- `/sl.dispatch` é a porta de entrada (decompõe um plan/feature e roda o pipeline).
- `sl-subagent-driven-development` continua dono do **loop de review** entre tasks; esta skill
  adiciona **paralelismo + roteamento de modelo + gates**.
- Vetos (V0/V1/V2) vêm de `sl-veto-conditions`.
- Aprendizados de execução (o que escalou, o que ficou caro) alimentam `/sl.kaizen`.

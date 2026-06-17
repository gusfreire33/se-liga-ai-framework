---
name: sl-dispatch
description: Parallel execution engine — decompose a plan/feature into atomic tasks, order them into DAG waves, route each to the cheapest sufficient model, and run them across subagents with veto gates
---

# Dispatch (Parallel Execution Engine)

> **LANG:** Respond in user's native language (detect from input). Tech terms always in English.
> **OWNER:** Adapt detail level to owner profile from status.sh (beginner → explain why; advanced → essentials only).
> **SAFETY:** Never dispatch a task that fails a V1 veto. Confirm scope before spawning subagents that write files.

Entry point for parallel execution. Loads the **`sl-parallel-dispatch`** skill (DAG waves, model
routing, CODE > LLM) and enforces gates from **`sl-veto-conditions`**. Use it to run a `plan.md` or
a feature across many subagents cheaply and in parallel.

## Argumentos / Modos

| Argumento | Ação |
|-----------|------|
| `<plan.md \| descrição>` | Pipeline completo: decompõe → roteia → planeja waves → gates → executa → relatório. |
| `plan` | Só até o plano de waves (decompose + route + wave plan), sem executar. Mostra o DAG e o custo estimado. |
| `route` | Mostra, por task, o executor e o modelo escolhidos (Worker/Haiku/Sonnet/Opus) e o porquê. |
| `run` | Executa um plano de waves já aprovado. |

Sem argumento: assuma o `plan.md` do branch atual; se não houver, peça a fonte.

## Fluxo (7 fases — ver skill `sl-parallel-dispatch`)

1. **Sufficiency (V0)** — input bem-definido? critério de aceite? entregáveis? Senão, redirecione (`/sl.new`, `/sl.plan`).
2. **Decompose** — quebre em tasks atômicas: 1 entregável + output path + critério mensurável cada.
3. **Route** — aplique a árvore de decisão de modelo. Desça pro mínimo suficiente. CODE > LLM.
4. **Wave plan** — monte o DAG, rode `.codesl/scripts/wave-optimizer.sh` pra ordenar em waves e
   **detectar ciclos** (ciclo → veto V1.4, pare).
5. **Pre-exec gate (V1)** — rode os vetos sobre cada task (placeholder, sem output, sem modelo, vago).
   Qualquer hard_block → volta pro decompose, não executa.
6. **Execute** — por wave, dispare **subagentes em paralelo** (no Claude Code: vários `Agent`/Task na
   mesma mensagem). Contexto mínimo por task (MINIMAL/STANDARD/FULL). Loop de review entre tasks via
   `sl-subagent-driven-development`. Fallback: Haiku→Sonnet→Opus (máx retries); 3 escalonamentos seguidos → HALT.
7. **Post-exec gate (V2) + relatório** — arquivo existe/não-vazio/sem placeholder; custo vs estimativa.
   Feche com: waves executadas, tasks por modelo, custo total, falhas, e o que escalou (vira input pro `/sl.kaizen`).

## Regras inegociáveis

- Task que não é atômica **não despacha** — corrige no plano.
- Orquestração não raciocina: segue os scripts. Se precisar de Opus pra orquestrar, o script está quebrado.
- Nada de arquitetura/estratégia no despacho — isso é `/sl.plan`.

## Saída

Plano de waves (DAG + modelo + custo estimado) → após aprovação, execução paralela → relatório final
com custo real e aprendizados. Sugira `/sl.review` no resultado e `/sl.kaizen reflect` pra guardar o que aprendeu.

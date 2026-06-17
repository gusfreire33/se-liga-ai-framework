---
name: sl-continuous-improvement
description: "Use to capture durable engineering learnings and produce defensible improvement reports for a project — extracts patterns with 5 gates (Verified/Non-obvious/Reusable/Actionable/Empirical), ages them with an Ebbinghaus forgetting curve so what's reused survives and what's ignored decays, and emits evidence-backed recommendations (max 5, Evidence+Impact+Action+ROI). Powers the /sl.kaizen command and the kaizen agent."
---

# Continuous Improvement (Kaizen)

O sistema nervoso do projeto. Duas funções, ambas anti-bloat:

1. **Reflect** — destila aprendizados reais em padrões reutilizáveis e os mantém vivos só
   enquanto forem úteis (forgetting curve).
2. **Report** — varre o projeto e emite recomendações **defensáveis** (com evidência), no
   máximo 5, priorizadas. Sem palpite.

Acionada por `/sl.kaizen` (sob demanda — sem hooks) e pelo agente `kaizen`.

## When to Use

- Fim de uma feature/sprint: "o que aprendemos que vale guardar?"
- Saúde do projeto: "onde está o gargalo, e o que mexer primeiro?"
- Antes de um refactor/investimento: validar que a dor é real (N≥3), não intuição

## When NOT to Use

- Tarefa de implementação (use `/sl.build`) ou auditoria técnica pontual (use `/sl.audit`)
- Registrar fato único e óbvio — isso é commit message, não padrão

## Parte 1 — Reflect: extração de padrões (5 gates)

Um aprendizado só vira **pattern** se passar nos **5 critérios** (todos obrigatórios):

| Gate | Pergunta | Falha se… |
|------|----------|-----------|
| **VERIFIED** | Observado 2+ vezes independentes OU documentado (git/docs)? | 1 só ocorrência, especulação ("acho que…") |
| **NON-OBVIOUS** | É insight novo (não está nos patterns) ou contradiz crença antiga? | já documentado, ou senso comum |
| **REUSABLE** | Aplica a >1 cenário? | edge case único, irrepetível |
| **ACTIONABLE** | Tem gatilho **e** ação (se X, então Y)? | só observação, sem o que fazer |
| **EMPIRICAL** | Rastreável a commit/código/observação real? | hearsay, hipótese não testada |

Falhou um? **REJEITA** e loga o motivo (vira candidato: "observe mais 1 vez"). Não infla os padrões.

Formato do pattern:
```yaml
- id: PAT-0007
  insight: "Hooks no Windows precisam de design async/fail-silent (timer.unref, não process.exit)"
  trigger: "Ao implementar qualquer hook no Windows"
  action: "Usar timer.unref() e deixar o Node sair naturalmente"
  evidence: "git: fix(hooks) … + observado em 2 sessões"
  verification_count: 2
  verified: true            # >=2 observações → decai mais devagar
  last_reinforced: 2026-06-16
  decay_score: 1.0
```

## Parte 1b — Forgetting curve (o que mantém vivo)

Memória decai exponencialmente sem reforço — e isso é uma feature, não um bug. Impede que os
padrões inchem com lixo velho.

```
decay_score(t) = e^(-rate × dias_sem_reforço)
  rate = 0.05  (geral)         → ~60 dias até o threshold de delete
  rate = 0.025 (verified, 2+x) → ~120 dias  (decai 2× mais devagar)
```

| decay_score | status | ação |
|-------------|--------|------|
| 1.0 | fresh | no briefing |
| ~0.5 (≈14d) | fading | no briefing + aviso "perto de arquivar" |
| < 0.1 (≈60d) | archive | move pro arquivo histórico |
| < 0.05 (≈120d) | delete | remove (loga no audit) |

**Reforço (spaced repetition):** padrão re-observado → `decay_score = 1.0`, `verification_count++`,
e se ≥2 vira `verified` (rate cai pra 0.025). Padrão usado fica "grudento"; padrão ignorado some sozinho.

Persistência (sob demanda, sem hooks): grave em `docs/kaizen/patterns.yaml` no projeto (ou em
`.codesl/intelligence/patterns.yaml`). O `/sl.kaizen reflect` recalcula os decay_scores na hora
de rodar (usa a data de hoje vs `last_reinforced`).

## Parte 2 — Report: recomendações defensáveis

Regra transversal (RULE-RD): **recomendação é baseada em EVIDÊNCIA, não opinião.**

Classifique cada evidência antes de recomendar:

| Classe | N | Pode virar… |
|--------|---|-------------|
| Métrica objetiva | — | ação direta |
| Padrão observado | N≥3 | recomendação / trial |
| Sinal fraco | N=1–2 | só "MONITORAR", nunca ação |
| Especulação | 0 | PROIBIDO em relatório |

**Regra do N<3:** padrão com menos de 3 ocorrências NÃO vira "gap crítico" nem justifica
investimento (novo agente, ferramenta, refactor grande). Vira "sinal a monitorar".

**GATE-RD-VERIFY (antes de recomendar remover/arquivar/integrar algo):**
1. `grep -r` no codebase — X é referenciado por outro arquivo?
2. Referenciado → reclassifica como MONITORAR (não é órfão).
3. Não referenciado → confirma com `git log --oneline -5 -- <arquivo>`.
4. Documenta o resultado do grep no relatório. **Sem grep, sem recomendação de remoção.**

Toda recomendação no relatório carrega 4 campos: **Evidência · Impacto · Ação · ROI** (vs custo de
não agir). Níveis: CRÍTICO / RECOMENDADO / SUGERIDO / MONITORAR.

**Limite: no máximo 5 recomendações.** *"Se você só fizer a #1, já valeu."* Priorize por impacto×evidência.

## Teste de defensibilidade (aplique a cada recomendação)

1. Se o dono perguntar "por que investir nisso?", a resposta tem **dados**? ("acho que ajuda" → fora)
2. Se ignorada, qual o impacto **mensurável**? (sem impacto claro → era especulação)
3. A recomendação sobreviveria com os dados da semana passada? (depende de 1 evento → sinal fraco)

## Anti-patterns (do caso de referência)

- Spec morta contada como feature (arquivo referenciado não existe) → evidência > presença.
- Alinhamento cosmético (renomear sem mudar função) → ROI = 0, não recomende.
- YAML onde texto funciona melhor → contexto importa, LLM não é parser.
- Score inflado com specs mortas → honestidade > métrica.

## Integração no SL

- `/sl.kaizen reflect` (extrai+envelhece padrões) · `/sl.kaizen report` (saúde+recomendações).
- Pontuação de saúde no report usa `sl-health-score` (fórmulas reproduzíveis).
- Recomendações de "remover/integrar" passam pelo GATE-RD-VERIFY (grep + git log).
- Aprendizados de execução vêm de `/sl.dispatch` (o que escalou, o que ficou caro).

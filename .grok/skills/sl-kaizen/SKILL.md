---
name: sl-kaizen
description: Continuous-improvement engine — reflect captured engineering learnings into durable patterns (5 gates + forgetting curve) and emit defensible, evidence-backed project recommendations (max 5)
---

# Kaizen (Continuous Improvement)

> **LANG:** Respond in user's native language (detect from input). Tech terms always in English.
> **OWNER:** Adapt detail level to owner profile from status.sh (beginner → explain the why; advanced → essentials only).
> **EVIDENCE:** No speculation in action recommendations. N<3 → "monitor", never "critical gap". No grep, no removal recommendation.

Loads the **`sl-continuous-improvement`** skill and dispatches the **`kaizen`** subagent. Runs on
demand (no hooks). Two jobs: keep durable learnings alive, and tell you what to fix first — with data.

## Argumentos / Modos

| Argumento | Ação |
|-----------|------|
| `reflect` | Extrai aprendizados da sessão/feature → aplica os **5 gates** → atualiza `patterns.yaml`, recalcula o **decay_score** de todos os padrões, arquiva/deleta os vencidos. |
| `report` | Varre o projeto, calcula o **health score** (skill `sl-health-score`) e emite **≤5 recomendações defensáveis** (Evidência+Impacto+Ação+ROI), priorizadas. |
| `brief` | Mostra os top padrões vivos (maior decay_score) — o "o que lembrar" do projeto. |

Sem argumento: rode `brief` e pergunte se quer `reflect` ou `report`.

## reflect — extração + envelhecimento

1. Reúna os aprendizados candidatos (do que aconteceu na sessão/feature, git log recente, falhas de `/sl.dispatch`).
2. Cada candidato passa pelos **5 gates** (todos obrigatórios): VERIFIED · NON-OBVIOUS · REUSABLE · ACTIONABLE · EMPIRICAL.
   Falhou um → REJEITA e loga o motivo (vira candidato pra próxima vez). Não infla.
3. Pattern aprovado: grava `{id, insight, trigger, action, evidence, verification_count, verified, last_reinforced, decay_score=1.0}`.
4. Já existe igual? **Reforça** (decay→1.0, count++, ≥2 vira `verified` com rate 0.025) em vez de duplicar.
5. **Recalcula decay** de todos: `e^(-rate × dias_desde_last_reinforced)`. <0.1 → arquiva; <0.05 → deleta (loga).
6. Persistência: `docs/kaizen/patterns.yaml` (cria se não existir). Sem hooks — você roda quando quiser.

## report — saúde + recomendações defensáveis

1. **Health score** por `sl-health-score` (fórmulas reproduzíveis, cite as contagens). A menor dimensão é candidata a CRÍTICO.
2. Classifique cada evidência: Métrica · Padrão (N≥3) · Sinal fraco (N=1-2) · Especulação(0, proibido).
3. **GATE-RD-VERIFY** antes de recomendar remover/arquivar/integrar: `grep -r` + `git log --oneline -5 -- <arquivo>`. Documente o resultado. Sem grep, sem recomendação de remoção.
4. Emita **no máximo 5** recomendações, cada uma com **Evidência · Impacto · Ação · ROI** e nível (CRÍTICO/RECOMENDADO/SUGERIDO/MONITORAR). *"Se só fizer a #1, já valeu."*

## Teste de defensibilidade (cada recomendação)

- "Por que investir nisso?" tem resposta com **dados**? Senão, fora.
- Se ignorada, qual o impacto **mensurável**? Sem impacto → era especulação.
- Sobreviveria com os dados da semana passada? Depende de 1 evento → sinal fraco (MONITORAR).

## Saída

`reflect` → resumo (N extraídos, N reforçados, N rejeitados+motivo, N arquivados/deletados).
`report` → health score + ≤5 recomendações priorizadas. Sugira `/sl.plan` na recomendação #1 se virar trabalho.

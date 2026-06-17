---
name: sl-health-score
description: "Use when scoring a codebase or area 0-100 in a reproducible way — explicit weighted dimensions with severity penalties and a Solid/Emerging/Ad-hoc classification, so the same code + same formula = same score, always. Strengthens sl.audit, sl.xray and sl.health-check, which otherwise grade by feel."
---

# Health Score (Reproducible 0–100)

Nota "no olho" não é auditável e muda a cada run. Esta skill define **fórmulas explícitas**:
mesmo codebase + mesma fórmula = mesma nota, sempre. Cada dimensão é medida por contagem
concreta, ponderada, com penalidade por severidade. Usada por `sl.audit`, `sl.xray`,
`sl.health-check` e pelo relatório do `/sl.kaizen`.

## When to Use

- Dar uma nota defensável a um projeto/módulo (e poder repetir a medição depois)
- Comparar "antes/depois" de um refactor com números, não impressão
- Priorizar onde mexer (a dimensão mais baixa puxa o plano)

## When NOT to Use

- Julgamento puramente qualitativo de design/UX (não force número onde não há métrica)

## Regras globais de pontuação

```yaml
range: [0, 100]
classifications:
  solid:    { min: 80, max: 100 }   # sólido
  emerging: { min: 50, max: 79 }    # em formação
  adhoc:    { min: 0,  max: 49 }    # ad-hoc / frágil
severity_penalties: { HIGH: -10, MEDIUM: -5, LOW: -2 }
rounding: half-up
clamping: always [0, 100]
final_per_dimension: "sum(dimension_value * weight) - severity_penalties"
```

Cada dimensão produz 0–100 por uma fórmula de contagem; o score da área é a soma ponderada
menos penalidades; depois clampa em [0,100]. **Scan → Score → Suggest:** mede de verdade
(grep/contagem real), pontua pela fórmula, e sugere o próximo passo a partir da menor dimensão.

## Fórmulas por dimensão (catálogo SDLC)

Genéricas pra qualquer stack — ajuste os globs ao projeto. `max(0, …)` em todas.

```yaml
codigo-componentes:           # estrutura do código
  - test_coverage   w=0.30  "(unidades_com_teste / total) * 100"
  - orphan_ratio    w=0.25  "((total - orfaos) / total) * 100"          # exportado, nunca importado
  - complexity      w=0.25  "((total - god_units) / total) * 100"        # god = >200 LOC ou >5 deps
  - structure       w=0.20  "((total - sem_error_handling) / total) * 100"

tipos:                        # type safety
  - strictness w=0.40  "max(0, 100 - any_count*3 - ts_nocheck*20)"
  - safety     w=0.35  "max(0, 100 - unsafe_casts*5 - assertions*3)"
  - coverage   w=0.25  "(exports_tipados / total_exports) * 100"

dependencias:
  - security   w=0.35  "max(0, 100 - crit_vulns*20 - high_vulns*10 - med_vulns*3)"
  - freshness  w=0.25  "max(0, 100 - major_behind*15 - minor_behind*3)"
  - efficiency w=0.20  "max(0, 100 - heavy_deps*10)"                     # >100KB com alternativa leve
  - hygiene    w=0.20  "max(0, 100 - unused*5 - dup_versions*8)"

seguranca:
  - injection w=0.40  "max(0, 100 - eval_usage*25 - unescaped_input*15 - dangerous_sink*20)"
  - secrets   w=0.35  "max(0, 100 - exposed_keys*30 - tokens_in_source*25)"
  - storage   w=0.25  "max(0, 100 - sensitive_in_localstorage*15 - unencrypted*10)"

testes:
  - presence  w=0.40  "(arquivos_com_teste / arquivos_testáveis) * 100"
  - assertion w=0.35  "(testes_com_assert_real / total_testes) * 100"    # sem teste vazio/skip
  - critical  w=0.25  "(fluxos_críticos_cobertos / fluxos_críticos) * 100"

documentacao:
  - readme    w=0.30  "README existe + tem setup/run/deploy ? escala : 0"
  - api       w=0.35  "(endpoints/exports_documentados / total) * 100"
  - freshness w=0.35  "max(0, 100 - docs_desatualizados*10)"             # citam arquivo/flag inexistente
```

## Agregação (Unified Health Score)

```yaml
unified = sum(dimension_score * weight) clamp [0,100]
weights (ajuste por projeto; soma = 1.00):
  codigo-componentes: 0.20
  tipos:              0.12
  dependencias:       0.15
  seguranca:          0.18
  testes:             0.20
  documentacao:       0.15
classification: Solid (>=80) | Emerging (50-79) | Ad-hoc (<50)
```

## Saída padrão

```
Health: 64/100 (Emerging)
  testes ........... 38   ← menor dimensão (prioridade)
  seguranca ........ 72
  dependencias ..... 55  (2 high vulns)
  ...
Próximo passo: cobrir os 3 fluxos críticos sem teste (testes 38 → ~70).
```

Sempre cite **a contagem que gerou o número** (ex: "38 = 11/29 arquivos testáveis com teste") —
senão a nota não é reproduzível nem auditável.

## Integração no SL

- `sl.audit` / `sl.xray` / `sl.health-check` adotam estas fórmulas em vez de notas subjetivas.
- O **report** do `/sl.kaizen` usa o Unified Score como evidência objetiva (classe "métrica") —
  e a menor dimensão vira candidata a recomendação CRÍTICA (ver `sl-continuous-improvement`).
- Penalidades de severidade alinham com os achados de `sl-security-audit` e `sl-code-review`.

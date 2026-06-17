---
name: sl-veto-conditions
description: "Use when defining or enforcing quality gates that must BLOCK, not advise — turns narrative checklists into deterministic SE/ENTÃO conditions with check + threshold + action + severity. Load before sl.review, sl.done, sl-delivery-validation, or any gate where the LLM could rationalize a pass."
---

# Veto Conditions (Deterministic Quality Gates)

Princípio (Pedro Valério): **"Se o executor CONSEGUE fazer errado, VAI fazer errado."**

Checklist narrativo (`- [ ] o código está limpo?`) é burlável — o LLM se convence de que passou.
Uma **veto condition** não é conselho: é um bloqueio com um teste objetivo. Ou passa o `check`, ou
a ação é VETO. Esta skill define o formato e como plugar nos gates do SL.

## When to Use

- Endurecer gates de `sl.review`, `sl.done`, `sl-delivery-validation`, `sl.build`
- Validar prompts/tasks antes de despachar subagentes (ver `sl-parallel-dispatch`)
- Qualquer momento em que "o gate passou mas não devia" já aconteceu

## When NOT to Use

- Decisões que exigem julgamento subjetivo genuíno (use o agente, não um veto)
- Preferências de estilo sem critério mensurável (vira regra de lint, não veto)

## Anatomia de uma Veto Condition

```yaml
- id: V1.2                       # ID estável (V0=soft, V1=pre-exec, V2=pos-exec)
  condition: "Acceptance criterion is subjective"   # o que está errado
  check: "regex: (good|adequate|nice|quality|well-written)"  # teste OBJETIVO
  threshold: 0                   # valor de corte (quando aplicável)
  action: "VETO — Rewrite with measurable criteria"  # o que fazer ao falhar
  severity: hard_block           # soft_block | hard_block | warning
  examples:
    bad:  ["good quality", "well-written", "appropriate tone"]
    good: ["< 500 words", "contains CTA", "3+ sections", "file exists at path X"]
```

Regras de ouro do `check`:
- **Executável ou grep-ável** — `grep -c`, exit code, contagem, comparação numérica. Não "avalie se…".
- **Determinístico** — mesmo input → mesmo resultado. Sem "depende".
- **Uma condição = um motivo de falha.** Não empacote vários problemas num veto só.

## Os 3 Estágios (quando cada veto roda)

| Tier | Quando | Comportamento | Exemplos |
|------|--------|---------------|----------|
| **V0 — Sufficiency** | ANTES de começar | `soft_block`: redireciona com recomendação | input vago, sem critério de aceite, sem entregável definido |
| **V1 — Pre-execution** | depois de planejar, antes de executar | `hard_block`: volta pro planejamento corrigir | placeholder `[TODO]` no prompt, critério subjetivo, task com >1 entregável, dependência circular no DAG, sem output path |
| **V2 — Post-execution** | depois de executar, antes de aceitar | `hard_block`: marca FAILED, retry ou escala | arquivo de saída não existe / vazio, output contém placeholder, custo > 3× estimado (warning) |

Severidades:
- `soft_block` — não para tudo; redireciona ("isso é trabalho pro /sl.new, não pro build").
- `hard_block` — para e exige correção. Não passa.
- `warning` — registra e segue, mas aparece no relatório.

## Catálogo base (pronto pra adaptar)

Copie e ajuste por projeto. Estes são os de maior valor universal em SDLC:

```yaml
sufficiency:        # V0 — soft block
  - { id: V0.1, condition: "Sem critério de aceite", check: "grep -ci 'aceite|acceptance' <spec> == 0", action: "VETO — rode /sl.new ou defina critérios", severity: soft_block }
  - { id: V0.2, condition: "Escopo ambíguo (<10 palavras, sem entregável)", check: "word_count<10 AND nenhum arquivo/quantidade citado", action: "VETO — peça entregáveis concretos", severity: soft_block }

pre_execution:      # V1 — hard block
  - { id: V1.1, condition: "Task sem output path", check: "task.output_path is None", action: "VETO — defina o arquivo de saída", severity: hard_block }
  - { id: V1.2, condition: "Critério de aceite subjetivo", check: "regex: (good|adequate|nice|quality|melhor|adequado)", action: "VETO — reescreva mensurável", severity: hard_block }
  - { id: V1.3, condition: "Prompt/código com placeholder", check: "regex: (\\[TODO\\]|\\[XXX\\]|TBD|\\[PLACEHOLDER\\]|FIXME)", action: "VETO — resolva todos os placeholders", severity: hard_block }
  - { id: V1.4, condition: "Dependência circular no plano de waves", check: "wave-optimizer.sh --check-cycles != 0", action: "VETO — conserte o grafo de dependências", severity: hard_block }
  - { id: V1.7, condition: "Task com múltiplos entregáveis", check: "count_deliverables(task) > 1", action: "VETO — 1 task = 1 entregável", severity: hard_block }
  - { id: V1.9, condition: "Verbo vago sem especificidade", check: "regex: (melhore|otimize|refatore|arrume) sem alvo concreto", action: "VETO — troque por ação específica", severity: hard_block }
  - { id: V1.10, condition: "Task sem modelo atribuído", check: "task.model is None", action: "VETO — rode o roteamento (sl-parallel-dispatch)", severity: hard_block }

post_execution:     # V2 — hard block / warning
  - { id: V2.1, condition: "Arquivo de saída não existe", check: "! test -f <output_path>", action: "VETO — task falhou, retry/escala", severity: hard_block }
  - { id: V2.2, condition: "Arquivo de saída vazio", check: "test ! -s <output_path>", action: "VETO — output vazio", severity: hard_block }
  - { id: V2.4, condition: "Output contém placeholder", check: "grep -E '\\[TODO\\]|TBD|\\[INSERT\\]' <output>", action: "VETO — não executou de fato", severity: hard_block }
  - { id: V2.3, condition: "Custo > 3× estimado", check: "actual > 3*estimate", action: "Revisar eficiência do prompt", severity: warning }
```

## Padrão de script de validação

Sempre que houver `.codesl/`, o gate vira um loop com exit code — não prosa:

```bash
ERRORS=0
# cada check vira uma linha objetiva:
grep -qiE 'good|adequate|nice|quality' "$SPEC" && { echo "❌ V1.2: critério subjetivo"; ERRORS=$((ERRORS+1)); }
grep -qE '\[TODO\]|\[XXX\]|TBD|FIXME' "$OUT"  && { echo "❌ V1.3: placeholder presente"; ERRORS=$((ERRORS+1)); }
test -s "$OUT" || { echo "❌ V2.2: output vazio"; ERRORS=$((ERRORS+1)); }

if [ "$ERRORS" -eq 0 ]; then echo "=== TODOS OS VETOS PASSARAM ==="; exit 0
else echo "=== BLOQUEADO: $ERRORS vetos disparados ==="; exit 1; fi
```

## Como plugar nos gates existentes do SL

- **`sl-code-review` / `sl.review`** — antes de declarar "aprovado", rode os V2 sobre o diff
  (placeholders, arquivos vazios, TODO/FIXME novos, critério de aceite mensurável).
- **`sl-delivery-validation`** — cada requisito vira um veto com `check` (o requisito está
  implementado de forma verificável?). Sem evidência objetiva → `hard_block`.
- **`sl.done`** — V2 sobre o entregável final + V1.3 (nenhum placeholder commitado).
- **`sl-parallel-dispatch`** — V0/V1 antes de despachar cada wave; V2 ao coletar resultados.

## Anti-rationalization (regras inegociáveis)

- Um veto sem `check` objetivo **não é veto** — é opinião. Reescreva ou remova.
- "Quase passou" = NÃO passou. `hard_block` não tem 90%.
- Se você está prestes a justificar por que pular um veto, **esse é o momento exato pra que ele existe.**
- Veto que dispara sempre (ruído) ou nunca (decorativo) → calibre o threshold ou delete.

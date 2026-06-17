# Fluxos

Combinações de comandos para diferentes tamanhos de trabalho. Escolha pelo contexto —
do mais completo ao mais enxuto.

## Completo

Para features grandes ou times que querem rastreabilidade total.

```text
/sl.init → /sl.new → /sl.plan → /sl.build → /sl.review → /sl.test → /sl.done
```
Onboarding, spec, plano, execução, revisão, testes e entrega documentada.

## Padrão

O dia a dia de uma feature bem definida (sem onboarding repetido).

```text
/sl.new → /sl.plan → /sl.build → /sl.review → /sl.done
```

## Com banco de dados

Feature que mexe no schema (tabelas novas, RLS, migrations). O `/sl.db` entra **entre o
plano e o build** — você desenha/migra o banco antes de construir contra ele.

```text
/sl.new → /sl.plan → /sl.db → /sl.build → /sl.review → /sl.done
```
`sl.db` dispatcha o agente **`data-engineer`** (schema, migrations com rollback, RLS,
otimização). Em banco já existente, use `/sl.db audit` depois de `/sl.xray` ou `/sl.audit`.

## Enxuto (Lean)

Mudança pequena e clara, com qualidade garantida.

```text
/sl.plan → /sl.build → /sl.review
```

## Execução paralela

Plano com muitas tarefas independentes — fan-out em waves com roteamento de modelo.

```text
/sl.plan → /sl.dispatch → /sl.review → /sl.done
```
`sl.dispatch` decompõe em waves (DAG), roteia cada tarefa pro modelo mais barato suficiente
e roda em subagentes com gates de veto.

## Melhoria contínua

Depois de entregar, capture o que aprendeu e veja o que melhorar no projeto.

```text
/sl.kaizen reflect   (guarda padrões)   ·   /sl.kaizen report   (recomendações + health score)
```

## Autônomo

Deixa o coordenador tocar plan → build → review sozinho.

```text
/sl.autopilot
```
Ideal quando o escopo já está claro e você quer o resultado com mínima interação.

## Emergência (Hotfix)

Bug em produção, sem cerimônia.

```text
/sl.diagnose → /sl.hotfix → /sl.done
```
`diagnose` confirma a rota; `hotfix` aplica a correção; `done` fecha com changelog.

---

## Como escolher

| Situação | Fluxo |
|----------|-------|
| Projeto novo, feature grande | Completo |
| Feature normal do backlog | Padrão |
| Feature mexe no banco (schema/RLS/migration) | Com banco de dados |
| Ajuste pequeno e claro | Enxuto |
| Plano com muitas tarefas independentes | Execução paralela |
| Escopo definido, quer agilidade | Autônomo |
| Produção quebrada | Emergência |
| Guardar aprendizados / melhorar o projeto | Melhoria contínua |

Veja casos reais em [Cenários](/reference/scenarios).

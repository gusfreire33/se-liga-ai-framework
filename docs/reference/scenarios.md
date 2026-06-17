# Cenários

Casos reais e o fluxo recomendado para cada um.

## "Comecei um projeto do zero"

```text
/sl.init → /sl.new → /sl.plan → /sl.build → /sl.review → /sl.done
```
Faça o onboarding uma vez (`sl.init`); depois cada feature segue o fluxo padrão.

## "Tenho um codebase legado e não sei a arquitetura"

```text
/sl.xray → /sl.audit
```
`xray` mapeia a arquitetura e gera padrões do projeto; `audit` aponta dívidas e riscos.
Depois siga com `/sl.new` para novas features — o método já conhece o terreno.

## "Preciso adicionar uma feature bem definida"

```text
/sl.new → /sl.plan → /sl.build → /sl.review → /sl.done
```
O fluxo Padrão. `sl.new` fixa os requisitos antes de codar.

## "Minha feature mexe no banco (schema novo, RLS, migration)"

```text
/sl.new → /sl.plan → /sl.db → /sl.build → /sl.review → /sl.done
```
O `/sl.db` entra **depois do plano e antes do build** — dispatcha o agente `data-engineer`
para desenhar o schema físico, escrever a migration **com rollback** e as RLS policies, e só
então você constrói contra o banco. Modos: `schema`, `migration`, `rls`, `optimize`, `audit`,
`run-sql`. Em banco já existente e desconhecido, rode `/sl.db audit` (combina com `/sl.xray`).

## "Tenho muitas tarefas independentes e quero rapidez"

```text
/sl.plan → /sl.dispatch → /sl.review → /sl.done
```
`sl.dispatch` decompõe o plano em waves paralelas (DAG), roteia cada tarefa pro modelo mais
barato suficiente e roda em subagentes — bem mais rápido e barato que tudo em série.

## "Bug crítico em produção, agora"

```text
/sl.diagnose → /sl.hotfix → /sl.done
```
`diagnose` confirma que é hotfix (e não uma feature disfarçada); `hotfix` corrige rápido.

## "Quero que a IA toque sozinha"

```text
/sl.autopilot
```
Para escopo já claro. Ele roda plan → build → review e te entrega o resultado.

## "A tela tá feia / quero padronizar o visual"

```text
/sl.design   (ou /sl.ux para ajustes pontuais)
```
A skill `sl-ux-design` traz metodologia (Leis de UX, DQS, padrões SaaS) **e** tokens de
marca via `DESIGN.md` — dá pra pedir "com a cara da Linear/Stripe".

## "Vou abrir um PR"

```text
/sl.pull-request
```
Idempotente: cria o PR ou atualiza o existente, gerando o changelog da feature.

## "Quero subir a cobertura de testes"

```text
/sl.test
```
Detecta o framework de testes e gera em paralelo por área, mirando ~80%.

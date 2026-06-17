# Quickstart

Do zero à primeira feature entregue em 6 passos. Comandos no formato Claude/Codex
(`/sl.x`); em Grok/Antigravity, acione a skill de mesmo nome (`sl-x`).

## 0. Preparar o projeto

```bash
npx github:gusfreire33/se-liga-ai-framework init   # cria .codesl/ no projeto
```

## 1. Onboarding (uma vez por projeto)

```text
/sl.init
```
Coleta o perfil do dono e gera o blueprint do produto (`docs/owner.md`, `docs/product.md`).
Define o tom e o nível de detalhe das respostas seguintes.

## 2. Descobrir a feature

```text
/sl.new
```
Levanta requisitos e escreve `about.md` (regras de negócio, escopo, decisões) — a **spec**.

## 3. Planejar

```text
/sl.plan
```
Gera `plan.md`: tarefas sequenciadas, mapeamento de arquivos, dependências e estimativas.
Detecta épico vs. feature.

## 3.5. Banco de dados (se a feature mexe no schema)

```text
/sl.db
```
Antes de construir, modele o banco: o `/sl.db` dispatcha o agente **`data-engineer`** para
desenhar o schema físico, gerar migration **com rollback** e RLS policies. Pule este passo se
a feature não toca em banco. (Modos: `schema`, `migration`, `rls`, `optimize`, `audit`.)

## 4. Implementar

```text
/sl.build
```
Executa o plano, despachando subagentes por área (Backend, Frontend, Database) e
registrando decisões. Não faz commit por conta própria. Com muitas tarefas independentes,
troque por `/sl.dispatch` (waves paralelas + roteamento de modelo).

## 5. Revisar até 100%

```text
/sl.review
```
Revisa qualidade, segurança (OWASP), arquitetura e contratos — com auto-correção até
passar tudo.

## 6. Entregar

```text
/sl.done
```
Finaliza o branch: changelog, documentação e merge (o `done.sh` é o dono da sequência).

---

## Atalhos úteis

| Situação | Comando |
|----------|---------|
| Não sei por onde começar | `/sl` (gateway, orienta) |
| Bug urgente em produção | `/sl.hotfix` |
| Feature inteira sem interação | `/sl.autopilot` |
| Mapear arquitetura de um repo existente | `/sl.xray` |
| Auditoria técnica / saúde | `/sl.audit` |
| Banco: schema, migration, RLS, otimização | `/sl.db` |
| Muitas tarefas independentes (paralelo) | `/sl.dispatch` |
| Guardar aprendizados / melhorar o projeto | `/sl.kaizen` |
| Refinar UI / design | `/sl.ux`, `/sl.design` |

Veja todos em [Comandos](/reference/commands) e combinações em [Fluxos](/reference/flows).

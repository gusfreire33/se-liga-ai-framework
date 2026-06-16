# Comandos

18 comandos, agrupados por etapa do ciclo. Notação `/sl.x` (Claude/Codex); em Grok e
Antigravity, cada comando é exposto como a skill `sl-x`.

## Gateway

| Comando | O que faz |
|---------|-----------|
| **`/sl`** | Ponto de entrada inteligente. Responde dúvidas, guia o fluxo e sugere o próximo comando. Comece por aqui se estiver perdido. |

## Descoberta

| Comando | O que faz |
|---------|-----------|
| **`/sl.init`** | Onboarding do projeto: coleta perfil do dono e gera o blueprint (`docs/owner.md`, `docs/product.md`). |
| **`/sl.new`** | Descoberta completa da feature + documentação: cria `about.md` com regras de negócio e escopo antes de qualquer código. |
| **`/sl.brainstorm`** | Parceiro de conversa para explorar ideias (READ-ONLY) — não altera arquivos. |

## Planejamento

| Comando | O que faz |
|---------|-----------|
| **`/sl.plan`** | Orquestrador de planejamento técnico: cria `plan.md` com tarefas sequenciadas, mapa de arquivos e estimativas. Detecta épico vs. feature. |

## Implementação

| Comando | O que faz |
|---------|-----------|
| **`/sl.build`** | Executa a implementação coordenando subagentes (Backend, Frontend, Database). Não faz commit sozinho. |
| **`/sl.autopilot`** | Coordenador autônomo: roda planejamento → desenvolvimento → revisão sem interação. |

## Dados (Banco)

| Comando | O que faz |
|---------|-----------|
| **`/sl.db`** | Engenharia de dados (PostgreSQL/Supabase): schema, migrations com rollback, RLS policies, otimização de query e operações. Dispatcha o agente **`data-engineer`**. Modos: `schema`, `migration`, `rls`, `optimize`, `audit`, `run-sql`, `setup`. |

## Qualidade

| Comando | O que faz |
|---------|-----------|
| **`/sl.review`** | Revisão de código com auto-correção até 100% (qualidade, OWASP, arquitetura, contratos). |
| **`/sl.test`** | Geração automática de testes mirando ~80% de cobertura; detecta o framework e roda em paralelo por área. |
| **`/sl.audit`** | Auditoria técnica completa: documentação, segurança, arquitetura, análise de dados. |
| **`/sl.diagnose`** | Triagem investigativa pré-decisão para sintomas ambíguos; recomenda a rota (hotfix/feature/no-action). |

## Entrega

| Comando | O que faz |
|---------|-----------|
| **`/sl.done`** | Finaliza o branch: changelog, documentação e merge (via `done.sh`). |
| **`/sl.pull-request`** | PR idempotente do branch atual: cria ou atualiza, gerando changelog da feature. |

## Utilidades & UX

| Comando | O que faz |
|---------|-----------|
| **`/sl.hotfix`** | Correção rápida de bug, com modo urgente para produção. |
| **`/sl.xray`** | Descoberta e mapeamento de arquitetura: classifica apps, despacha analisadores, consolida relatório. |
| **`/sl.ux`** | Refinamento leve de UX a partir de instruções livres. |
| **`/sl.design`** | Especialista de UX para SaaS: design mobile-first autônomo com fluxos de tela e specs de componentes. |

> Os comandos carregam [skills](/deep-dive/skills) sob demanda e chamam o
> [runtime](/deep-dive/project-structure) `.codesl/scripts` quando precisam de operações
> determinísticas (status, IDs, merge).

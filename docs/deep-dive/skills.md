# Skills

37 módulos de conhecimento de domínio. Skills **carregam sozinhas** por relevância
semântica (o campo `description` é o gatilho) e também são acionáveis diretamente.
`SKILL.md` é um padrão **cross-agent** — o mesmo arquivo roda em todos os CLIs.

## Produto & Descoberta

| Skill | Para que serve |
|-------|----------------|
| `sl-product-discovery` | Início de projeto: descobre perfil do fundador e blueprint (`owner.md`, `product.md`). |
| `sl-feature-discovery` | Análise do codebase para uma feature; cria/atualiza `discovery.md`. |
| `sl-feature-specification` | Documenta requisitos da feature em `about.md` (regras, escopo, decisões). |
| `sl-investigation` | Diagnóstico diferencial para sintomas vagos antes de corrigir. |

## Planejamento & Docs

| Skill | Para que serve |
|-------|----------------|
| `sl-planning` | Cria/atualiza `plan.md` com tarefas, mapa de arquivos e estimativas S/M/L. |
| `sl-plan-based-features` | Features com gating por plano, flags e limites. |
| `sl-tasks-checklist` | Schema e regras de marcação do `tasks.md`. |
| `sl-doc-schemas` | Fonte de verdade das regras de documentação (depth floors, IDs, validação). |
| `sl-doc-reviewer` | Revisa um doc recém-escrito como stakeholder fresco (gaps, clareza, escopo). |
| `sl-id-convention` | Convenção `[NNNN][L]` de IDs de feature/hotfix/branch. |

## Arquitetura

| Skill | Para que serve |
|-------|----------------|
| `sl-architecture-discovery` | Documenta arquitetura (Technical Spec no CLAUDE.md). |
| `sl-backend-architecture` | Decisões estruturais de backend (slices, camadas, organização). |
| `sl-frontend-architecture` | Estrutura de projeto front (pastas, fronteiras, escala). React/Vue/Angular. |
| `sl-project-scaffolding` | Scaffolding Node.js (monolito Starter, monorepo Scale). |

## Desenvolvimento

| Skill | Para que serve |
|-------|----------------|
| `sl-backend-development` | API backend: Clean Architecture, SOLID, DTOs, Services, Repositories. |
| `sl-frontend-development` | Front: estado, data fetching, componentes, forms, routing. |
| `sl-database-development` | Entidades, repositórios, migrations, multi-tenancy (camada app/ORM). |
| `sl-data-engineering` | **Camada DBA/SQL:** PostgreSQL & Supabase, RLS, migrations com rollback, EXPLAIN, índices, templates SQL. Usada pelo agente `data-engineer` / `/sl.db`. |
| `sl-stripe` | Stripe: billing, assinaturas, versionamento de preços, grandfathering. |
| `sl-ux-design` | UI/UX para SaaS: Leis de UX, DQS, padrões + tokens `DESIGN.md` por marca. |

## Qualidade & Segurança

| Skill | Para que serve |
|-------|----------------|
| `sl-code-review` | Revisão: IoC, RESTful, contratos, OWASP, Clean Architecture, SOLID. |
| `sl-security-audit` | Auditoria de segurança: OWASP Top 10, multi-tenancy, injeção, auth, XSS. |
| `sl-health-check` | Saúde técnica: documentação, segurança, arquitetura, dados. |
| `sl-health-score` | Scoring 0-100 reproduzível: dimensões ponderadas + penalidades por severidade (Solid/Emerging/Ad-hoc). Usada por `/sl.audit`, `/sl.xray`, `/sl.kaizen`. |
| `sl-veto-conditions` | Gates de qualidade que **bloqueiam de verdade** (check + threshold + ação + severidade). Endurece `/sl.review`, `/sl.done`, `/sl.dispatch`. |
| `sl-delivery-validation` | Validação de produto: requisitos 100% implementados, critérios de aceite. |

## Fluxo de trabalho & Ferramentas

| Skill | Para que serve |
|-------|----------------|
| `sl-subagent-driven-development` | Execução de planos via subagentes despachados, com review entre tarefas. |
| `sl-parallel-dispatch` | Motor de execução paralela: waves (DAG), roteamento de modelo (Worker/Haiku/Sonnet/Opus), CODE > LLM. Usada por `/sl.dispatch`. |
| `sl-continuous-improvement` | Kaizen: extração de padrões (5 gates) + forgetting curve + recomendações defensáveis. Usada por `/sl.kaizen` e pelo agente `kaizen`. |
| `sl-commit` | Commits inteligentes: Conventional Commits, detecção de tipo, staging. |
| `sl-optimizing-git-workflow` | Config global de git (cores, performance, aliases) para máquinas novas. |
| `sl-dev-environment-setup` | Detecta/instala bash, git, jq, gh quando faltam. |
| `sl-resource-path-convention` | Caminhos de recursos que resolvem certo em todos os providers. |
| `sl-claude-md-style` | Regras de estilo do CLAUDE.md (o que entra, formato, orçamento de linhas). |
| `sl-token-efficiency` | Padrões de compressão para comandos/skills/docs. |
| `sl-skill-creator` | Criar, atualizar e otimizar skills. |
| `sl-ecosystem` | Visão consolidada do ecossistema (carregada pelo gateway `/sl`). |

> Detalhe da `sl-ux-design`: além da metodologia, ela integra **DESIGN.md** (specs de
> tokens visuais por marca, de [voltagent/awesome-design-md](https://github.com/voltagent/awesome-design-md)),
> permitindo "construa com a cara da Linear/Stripe/Vercel".

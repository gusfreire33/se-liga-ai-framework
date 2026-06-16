---
name: sl-data-engineering
description: "Use for database engineering at the SQL/DBA layer — PostgreSQL & Supabase schema design, migrations (with rollback), Row Level Security (RLS) policies, query optimization (EXPLAIN), indexing, and safe data operations. Complements sl-database-development (app/ORM layer)."
---

# Data Engineering (PostgreSQL / Supabase)

Camada **DBA/SQL**: modelagem física, migrations seguras, RLS, performance e operações
no banco. Para a camada de aplicação (ORM, repositórios, entidades), use
`sl-database-development`. Acionada pelo comando `/sl.db` e pelo agente `data-engineer`.

## When to Use

- Desenhar schema físico (tabelas, constraints, índices) em Postgres/Supabase
- Escrever migration **com script de rollback** e snapshot
- Criar/auditar **RLS policies** (multi-tenant, por papel, KISS vs granular)
- Otimizar queries (EXPLAIN ANALYZE), desenhar índices por padrão de acesso
- Operações seguras: seed idempotente, carga de CSV (staging→merge), run-SQL transacional

## When NOT to Use

- Lógica de aplicação / ORM / repositórios → `sl-database-development`
- Arquitetura de pastas/camadas do backend → `sl-backend-architecture`

## Princípios (inegociáveis)

1. **Correção antes de velocidade** — acerte o modelo, otimize depois (com EXPLAIN).
2. **Tudo versionado e reversível** — toda mudança de schema tem snapshot + rollback.
3. **Segurança por padrão** — RLS + constraints + checks + triggers (defense-in-depth).
4. **Idempotência** — operações seguras de rodar 2x (`IF NOT EXISTS`, `ON CONFLICT`).
5. **Access-pattern first** — índices servem queries reais, não suposições.
6. **Baseline de toda tabela:** `id` (PK), `created_at`, `updated_at`; `deleted_at` se precisar de soft delete.
7. **FKs sempre** — integridade no banco, não só na app.
8. **Zero-downtime como meta** — migrations em passos seguros (add nullable → backfill → constraint).
9. **Nunca exponha segredos** — redija senhas/tokens; use Pooler + `sslmode=require` em produção.

## Segurança RLS (essencial)

- `auth.uid()` retorna NULL sem camada de Auth — avise se não houver.
- **Service role bypassa RLS** — use com extremo cuidado.
- Toda policy validada com casos **positivos E negativos** (`*test-as-user`).
- Multi-tenant: isole por `tenant_id`/`org_id` com policy em TODAS as tabelas sensíveis.

## Referências (carregar sob demanda)

| Arquivo | Conteúdo |
|---------|----------|
| `references/supabase-patterns.md` | Estrutura de projeto, Auth, Storage, Realtime, Edge Functions, Pooler |
| `references/postgres-tuning-guide.md` | EXPLAIN, índices, vacuum, connection pooling, tuning |
| `references/rls-security-patterns.md` | Padrões de RLS (tenant, papel, owner), pitfalls |
| `references/migration-safety-guide.md` | Migrations zero-downtime, ordem de DDL, rollback |
| `references/database-best-practices.md` | Naming, tipos, constraints, soft delete, auditoria |

## Templates SQL (`templates/`)

| Template | Uso |
|----------|-----|
| `migration-script.sql` | Esqueleto de migration (transacional, idempotente) |
| `rollback-script.sql` | Script de reversão pareado |
| `rls-tenant.sql` | RLS multi-tenant por `tenant_id` |
| `rls-kiss-policy.sql` | RLS mínima (KISS) |
| `rls-granular-policies.sql` | RLS por operação (select/insert/update/delete) |
| `rls-roles.sql` | RLS por papel/role |
| `comment-on-examples.sql` | `COMMENT ON` para documentar schema |

## Fluxo recomendado

```
modelar domínio → desenhar schema → migration + rollback → snapshot →
dry-run → aplicar → RLS policies → test-as-user (±) → EXPLAIN/índices → checklist pré-deploy
```

> Runtime: operações que precisam de repetibilidade (IDs, status) usam `.codesl/scripts`.
> SQL destrutivo SEMPRE precedido de snapshot e dentro de transação.

---
description: Data Engineer for PostgreSQL/Supabase — schema design, safe migrations, RLS policies, query optimization and DB operations
---

# Data Engineer (PostgreSQL / Supabase)

> **LANG:** Respond in user's native language (detect from input). Tech terms always in English.
> **OWNER:** Adapt detail level to owner profile from status.sh (beginner → explain why; advanced → essentials only).
> **SAFETY:** Never echo secrets. Snapshot before destructive/schema-altering SQL. Service role bypasses RLS — flag it.

Entry point for database engineering at the SQL/DBA layer. Dispatches the **`data-engineer`**
subagent (loads the `sl-data-engineering` skill, RLS/migration templates and Postgres/Supabase guides).

## Modes

Pick by the argument, or ask the user which they need:

| Argumento | Ação |
|-----------|------|
| `schema` | Modelar domínio e desenhar o schema físico (tabelas, FKs, constraints, índices). |
| `migration` | Gerar migration **+ rollback** a partir de `templates/migration-script.sql`, com snapshot. |
| `rls` | Criar/auditar RLS policies (tenant / role / owner) usando os templates `rls-*.sql`. |
| `optimize` | Analisar performance: `EXPLAIN ANALYZE`, hotpaths, índices por padrão de acesso. |
| `audit` | Auditoria de segurança/qualidade do banco (RLS, schema, constraints). |
| `run-sql` | Executar SQL (arquivo ou inline) dentro de transação, com confirmação. |
| `setup` | Inicializar projeto de banco (Supabase/Postgres): estrutura, env, conexão Pooler+SSL. |

> Sem argumento: pergunte o objetivo e sugira o modo.

## Flow

1. **Context:** read `about.md`/`plan.md` if present; inspect existing schema/migrations and conventions.
   Run `bash .codesl/scripts/status.sh` if available (feature context).
2. **Dispatch** the `data-engineer` subagent with the chosen mode and the gathered context.
3. **Safety gates:**
   - Any schema-altering op → create a snapshot first; produce a paired rollback script.
   - RLS changes → validate with **positive AND negative** test cases (emulate a user).
   - Destructive SQL → require explicit user confirmation; wrap in a transaction.
4. **Deliver:** runnable SQL (migration + rollback), RLS with test cases, and a short rationale.
   Log the iteration via `.codesl/scripts/log-iteration.sh` when in a feature branch.

## Examples

```text
/sl.db schema           # desenhar o schema de uma feature
/sl.db migration        # gerar migration + rollback
/sl.db rls users        # RLS multi-tenant na tabela users
/sl.db optimize         # achar e corrigir queries lentas
/sl.db run-sql ./fix.sql
```

> Camada de aplicação (ORM, repositórios) → use `/sl.build` com a skill `sl-database-development`.

# Exemplo: `/sl.db` — Multi-tenant + RLS (Supabase)

Saída **real** do agente `data-engineer` para o comando:

```text
/sl.db schema    # SaaS de gestão de projetos, multi-tenant, Supabase
```

Cenário: um SaaS de gestão de projetos onde várias organizações coexistem no mesmo banco.
Isolamento por `organization_id`, aplicado via **RLS em todas as tabelas**.
Modelo de acesso: `auth.uid()` → `memberships` → `organization_id` → linhas permitidas.

> Este é o tipo de artefato que o Data Engineer entrega: schema + índices + RLS +
> migration/rollback + testes — seguindo os princípios da skill `sl-data-engineering`
> (correção antes de velocidade, tudo reversível, defense-in-depth, idempotência).

## 1. Schema

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Trigger genérica de updated_at (defina uma vez, use em todas as tabelas)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

-- organizations — tenant raiz
CREATE TABLE IF NOT EXISTS organizations (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  name       text        NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  slug       text        NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9\-]+$'),
  plan       text        NOT NULL DEFAULT 'free' CHECK (plan IN ('free','pro','enterprise')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz   -- soft delete: NULL = ativa
);
CREATE TRIGGER trg_organizations_updated_at
  BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- profiles — espelho de auth.users (PK = auth.users.id)
CREATE TABLE IF NOT EXISTS profiles (
  id         uuid        PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  full_name  text        NOT NULL CHECK (char_length(full_name) BETWEEN 1 AND 200),
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- memberships — usuário ↔ organização, com role
CREATE TABLE IF NOT EXISTS memberships (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid        NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  user_id         uuid        NOT NULL REFERENCES profiles (id)      ON DELETE CASCADE,
  role            text        NOT NULL DEFAULT 'member' CHECK (role IN ('owner','admin','member')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, user_id)   -- no máx. 1 papel por org
);
CREATE TRIGGER trg_memberships_updated_at
  BEFORE UPDATE ON memberships FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- projects — pertence a uma organização (soft delete)
CREATE TABLE IF NOT EXISTS projects (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid        NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
  name            text        NOT NULL CHECK (char_length(name) BETWEEN 1 AND 150),
  description     text,
  status          text        NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived','completed')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  deleted_at      timestamptz
);
CREATE TRIGGER trg_projects_updated_at
  BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- tasks — pertence a um projeto, assignee opcional (soft delete)
CREATE TABLE IF NOT EXISTS tasks (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id  uuid        NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
  title       text        NOT NULL CHECK (char_length(title) BETWEEN 1 AND 300),
  description text,
  status      text        NOT NULL DEFAULT 'todo'
                          CHECK (status IN ('todo','in_progress','in_review','done','cancelled')),
  priority    smallint    NOT NULL DEFAULT 0 CHECK (priority BETWEEN 0 AND 3),
  assignee_id uuid                 REFERENCES profiles (id) ON DELETE SET NULL,
  due_date    date,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);
CREATE TRIGGER trg_tasks_updated_at
  BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

## 2. Índices (por padrão de acesso)

```sql
-- Índices parciais (WHERE deleted_at IS NULL) = menor footprint, scans mais rápidos.
CREATE INDEX IF NOT EXISTS idx_organizations_slug
  ON organizations (slug) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_memberships_user_id ON memberships (user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_org_id  ON memberships (organization_id);
-- covering index para is_member()/has_role() — evita heap fetch no hot path da RLS
CREATE INDEX IF NOT EXISTS idx_memberships_org_user_role
  ON memberships (organization_id, user_id, role);

CREATE INDEX IF NOT EXISTS idx_projects_org_id
  ON projects (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_projects_status
  ON projects (organization_id, status) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_project_id
  ON tasks (project_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_project_status
  ON tasks (project_id, status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_assignee
  ON tasks (assignee_id) WHERE deleted_at IS NULL AND assignee_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tasks_due_date
  ON tasks (due_date, status) WHERE deleted_at IS NULL AND due_date IS NOT NULL;
```

## 3. RLS Policies

Funções helper em `SECURITY DEFINER` + `SET search_path = ''` (evita recursão de RLS e
*search_path hijacking*); `STABLE` permite cache por transação.

```sql
CREATE OR REPLACE FUNCTION is_member(org_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org_id AND m.user_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION has_role(org_id uuid, required_role text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.memberships m
    WHERE m.organization_id = org_id AND m.user_id = auth.uid()
      AND CASE required_role
            WHEN 'owner'  THEN m.role = 'owner'
            WHEN 'admin'  THEN m.role IN ('owner','admin')
            WHEN 'member' THEN m.role IN ('owner','admin','member')
            ELSE false
          END
  );
$$;

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships   ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks         ENABLE ROW LEVEL SECURITY;

-- organizations: membros leem; só owner atualiza; DELETE bloqueado (use soft delete)
CREATE POLICY "orgs: members select" ON organizations
  FOR SELECT USING (deleted_at IS NULL AND is_member(id));
CREATE POLICY "orgs: owner update" ON organizations
  FOR UPDATE USING (has_role(id,'owner')) WITH CHECK (has_role(id,'owner'));
CREATE POLICY "orgs: authenticated insert" ON organizations
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- memberships: membros veem; admin+ insere/edita/remove
CREATE POLICY "memberships: select" ON memberships
  FOR SELECT USING (is_member(organization_id));
CREATE POLICY "memberships: admin insert" ON memberships
  FOR INSERT WITH CHECK (has_role(organization_id,'admin'));
CREATE POLICY "memberships: admin update" ON memberships
  FOR UPDATE USING (has_role(organization_id,'admin')) WITH CHECK (has_role(organization_id,'admin'));
CREATE POLICY "memberships: admin delete" ON memberships
  FOR DELETE USING (has_role(organization_id,'admin'));

-- projects: membros leem ativos; admin+ cria/edita
CREATE POLICY "projects: members select" ON projects
  FOR SELECT USING (deleted_at IS NULL AND is_member(organization_id));
CREATE POLICY "projects: admin insert" ON projects
  FOR INSERT WITH CHECK (has_role(organization_id,'admin'));
CREATE POLICY "projects: admin update" ON projects
  FOR UPDATE USING (has_role(organization_id,'admin')) WITH CHECK (has_role(organization_id,'admin'));

-- tasks: herdam o isolamento via projects.organization_id
CREATE POLICY "tasks: members select" ON tasks
  FOR SELECT USING (
    deleted_at IS NULL AND EXISTS (
      SELECT 1 FROM projects p
      WHERE p.id = tasks.project_id AND p.deleted_at IS NULL AND is_member(p.organization_id)
    )
  );
CREATE POLICY "tasks: members insert" ON tasks
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM projects p
            WHERE p.id = tasks.project_id AND p.deleted_at IS NULL AND is_member(p.organization_id))
  );
```

## 4. Migration + Rollback

```sql
-- 20240601001_up.sql  (transacional — qualquer erro reverte TUDO)
BEGIN;
  -- [schema + índices + RLS das seções acima]
  CREATE TABLE IF NOT EXISTS schema_migrations (
    version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now(), description text
  );
  INSERT INTO schema_migrations (version, description)
  VALUES ('20240601001', 'project management schema + RLS')
  ON CONFLICT (version) DO NOTHING;   -- idempotente
COMMIT;
```

```sql
-- 20240601001_rollback.sql  — DESTRUTIVO: snapshot ANTES!
-- pg_dump -Fc -f snapshot_$(date +%Y%m%d_%H%M%S).dump $DATABASE_URL
BEGIN;
  DROP TABLE IF EXISTS tasks, projects, memberships, profiles, organizations CASCADE;
  DROP FUNCTION IF EXISTS is_member(uuid), has_role(uuid,text), set_updated_at() CASCADE;
  DELETE FROM schema_migrations WHERE version = '20240601001';
COMMIT;
```

## 5. Testes de RLS (positivo + negativo)

Emula `auth.uid()` com `set_config` e roda como `authenticated`:

```sql
-- POSITIVO: Alice (membro org A) vê projetos da org A → 1 linha
BEGIN;
  SELECT set_config('request.jwt.claims', '{"sub":"...-0001-..."}', true);
  SET LOCAL ROLE authenticated;
  SELECT name FROM projects WHERE organization_id = '...org-A...';   -- → Project Alpha
ROLLBACK;

-- NEGATIVO: Alice NÃO vê projetos da org B → 0 linhas (isolamento OK)
BEGIN;
  SELECT set_config('request.jwt.claims', '{"sub":"...-0001-..."}', true);
  SET LOCAL ROLE authenticated;
  SELECT name FROM projects WHERE organization_id = '...org-B...';   -- → 0 linhas
ROLLBACK;

-- NEGATIVO: membro NÃO consegue adicionar membro (precisa admin/owner) → policy violation
BEGIN;
  SELECT set_config('request.jwt.claims', '{"sub":"...-0001-..."}', true);
  SET LOCAL ROLE authenticated;
  INSERT INTO memberships (organization_id, user_id, role) VALUES ('...org-A...','...','member');
  -- → ERROR: new row violates row-level security policy
ROLLBACK;
```

> O exemplo completo do agente inclui 7 testes (orgs/usuários de fixture, INSERT/UPDATE ± por papel).

## 6. Notas de segurança & performance

- **Service role bypassa RLS** — nunca exponha a `service_role` key no client; use só server-side.
- **`auth.uid()` é NULL sem sessão** — policies retornam 0 linhas (correto); para dados públicos, crie policy explícita `USING (true)`.
- **Índices da RLS são obrigatórios** — sem `idx_memberships_org_user_role` + `idx_projects_org_id`, cada query em `tasks` vira full scan. Valide com `EXPLAIN (ANALYZE, BUFFERS)`.
- **Pooler + SSL em produção:** `...:6543/postgres?sslmode=require` (Transaction Mode).
- **Soft delete acumula dead tuples** — autovacuum agressivo em tabelas de alta escrita.

---

### Resumo das decisões

| Decisão | Escolha | Por quê |
|---|---|---|
| Isolamento | `organization_id` + RLS em tudo | Sem leak cross-tenant; enforçado no banco |
| Soft delete | `deleted_at` em orgs/projects/tasks | Histórico + auditoria sem quebrar FKs |
| Roles | CHECK + `has_role()` (CASE) | Owner ≥ Admin ≥ Member sem tabela extra |
| FK on delete | CASCADE nos filhos, SET NULL no assignee | Task não some se o assignee sair |
| Funções RLS | `SECURITY DEFINER` + `search_path=''` | Sem recursão de RLS + hardening |
| Migration | `BEGIN/COMMIT` + `schema_migrations` | Atomicidade + idempotência |

> Gere o seu: `/sl.db schema`, depois `/sl.db rls <tabela>` e `/sl.db migration`.

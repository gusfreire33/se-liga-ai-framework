---
name: sl-ecosystem
description: Consolidated view of the sl-pro ecosystem - commands, skills, relationships and dependencies. Loaded by /sl as source of truth.
---

# Ecosystem Map - sl-pro

## When NOT to Use

- Not a how-to guide — load the specific skill for execution detail.
- Not for authoring new skills/commands → use `sl-skill-creator`.
- Not for resource path conventions → use `sl-resource-path-convention`.

## Commands

| Command | Purpose | Skills Loaded |
|---------|---------|---------------|
| add | Intelligent gateway - answers questions, guides flows, suggests next command | sl-ecosystem, sl-dev-environment-setup |
| sl.audit | Complete technical analysis of project (security, architecture, data, docs). Escalates to sl-investigation on ambiguous findings | sl-doc-schemas, sl-health-check, sl-ecosystem, sl-investigation |
| sl.autopilot | Autonomous Feature Coordinator | sl-backend-development, sl-database-development, sl-frontend-development, sl-ux-design, sl-tasks-checklist |
| sl.brainstorm | Explore ideas (READ-ONLY) | sl-doc-schemas, sl-ecosystem |
| sl.build | Development Execution Specialist | sl-backend-development, sl-database-development, sl-frontend-development, sl-ux-design, sl-code-review, sl-ecosystem, sl-id-convention, sl-tasks-checklist |
| sl.design | Mobile-first UX specification, coordinates subagents for complex features | sl-ux-design, sl-doc-schemas |
| sl.diagnose | Pre-decision investigative triage for ambiguous symptoms. Applies 5-phase methodology (disambiguation, RCA, patterns, differential diagnosis, synthesis) and recommends route (hotfix/feature/extend/no-action). READ-ONLY | sl-investigation, sl-ecosystem |
| sl.done | Finalize feature, generate changelog. Validates epics + requirements. Detects branch protection and routes to PR or direct merge | sl-ecosystem, sl-id-convention |
| sl.hotfix | Urgent fix with global ID ([NNNN]H). Creates isolated doc in docs/features/[NNNN]H-*, documents relationships in related.md. Escalates to sl-investigation when root cause not obvious | sl-ux-design, sl-ecosystem, sl-investigation, sl-id-convention |
| sl.init | Project onboarding - 3 questions (name, level, language), flat owner.md, optional product.md | sl-product-discovery |
| sl.new | Feature discovery, creates about.md | sl-feature-discovery, sl-feature-specification, sl-doc-schemas, sl-ecosystem |
| sl.plan | Technical Planning Orchestrator | sl-backend-development, sl-database-development, sl-frontend-development, sl-ux-design, sl-feature-discovery, sl-ecosystem, sl-id-convention, sl-tasks-checklist |
| sl.pull-request | Create or update PR for current branch (idempotent). On feature branches, generates the permanent feature changelog before opening the PR | sl-commit, sl-doc-schemas, sl-id-convention |
| sl.review | Feature Code Review Specialist | sl-code-review, sl-delivery-validation, sl-backend-development, sl-database-development, sl-frontend-development, sl-ux-design, sl-security-audit, sl-investigation |
| sl.test | Automated test generation (80% coverage). Parallel subagents per area + Startup Test | sl-backend-development, sl-frontend-development, sl-ecosystem |
| sl.ux | Quick UX - loads sl-ux-design and applies to user's free-form instruction | sl-ux-design |
| sl.xray | Map project architecture, classify apps, consolidate context | sl-architecture-discovery, sl-ecosystem |

## Skills

| Skill | Purpose |
|-------|---------|
| sl-architecture-discovery | Map architecture, detect patterns, generate project-patterns skill |
| sl-backend-architecture | Backend architecture consultant: Simple Modular, Vertical Slice, Clean Architecture, Combined Strategy |
| sl-backend-development | Backend architecture: SOLID, Clean Arch, DTOs, Services, Repository — stack-agnostic |
| sl-claude-md-style | CLAUDE.md generation guide: content rules, format (JSON/markdown), line budget — load before any CLAUDE.md write |
| sl-code-review | Code review: IoC, RESTful, Contracts, Security (OWASP), Clean Architecture, SOLID |
| sl-commit | Knowledge reference for mid-workflow commits: adaptive message logic, type detection, staging rules |
| sl-database-development | Data architecture: entities, repositories, migrations, naming — stack-agnostic |
| sl-delivery-validation | Product validation: Requirements 100% implemented, prerequisites exist, acceptance criteria pass |
| sl-dev-environment-setup | Detect OS, diagnose missing tools, install WSL/git/jq/gh, configure VS Code |
| sl-doc-schemas | Canonical schemas, stable IDs, universal doc rules, validation gate — single source of truth for all generated docs |
| sl-ecosystem | Consolidated ecosystem view (source of truth) |
| sl-feature-discovery | Feature discovery process, codebase analysis |
| sl-feature-specification | about.md structure with requirements, rules, acceptance criteria |
| sl-frontend-architecture | Frontend architecture consultant: Simple Component-Based, Feature-Based, FSD — React/Vue/Angular-aware |
| sl-frontend-development | Frontend architecture: state, data fetching, components, forms, routing — stack-agnostic |
| sl-health-check | Health check of environment and project dependencies |
| sl-id-convention | Canonical [NNNN][L] ID and branch naming convention for features, hotfixes, refactors, chores, and docs — enforced by scripts (next-id.sh, get-branch-metadata.sh, done.sh) |
| sl-investigation | Rigorous investigation methodology (5 phases with Iron Law) for vague symptoms and information-flow bugs. Adapted from systematic-debugging. Reusable by any command needing RCA before acting |
| sl-optimizing-git-workflow | Git patterns, commits, branches, aliases |
| sl-plan-based-features | Implement subscription plan-based features |
| sl-planning | Technical planning orchestration |
| sl-product-discovery | Product discovery (macro level) |
| sl-project-scaffolding | Create projects from scratch: Starter/Scale, multi-stack Node.js, Starter-to-Scale migration |
| sl-resource-path-convention | Path convention for referencing commands/skills/scripts across providers |
| sl-security-audit | OWASP checklist, RLS, secrets, multi-tenancy |
| sl-skill-creator | Create and test skills under real pressure |
| sl-stripe | Stripe integration, price versioning, grandfathering |
| sl-subagent-driven-development | Subagent coordination with quality gates |
| sl-tasks-checklist | tasks.md schema: 5 sections, tick rules, [!] semantics, "non-trivial change" rule, architect prompt template — single source of truth |
| sl-token-efficiency | Compression, compact JSON, minimal tokens |
| sl-ux-design | Components, mobile-first, SaaS patterns, shadcn, Tailwind |

## Dependency Index

| If you modify... | It impacts... |
|------------------|---------------|
| sl-backend-development | sl.build, sl.autopilot, sl.plan, sl.review, sl.test |
| sl-frontend-development | sl.build, sl.autopilot, sl.plan, sl.review, sl.test |
| sl-database-development | sl.build, sl.autopilot, sl.plan, sl.review, sl.test |
| sl-ux-design | sl.design, sl.ux, sl.build, sl.autopilot, sl.review, sl.hotfix, sl.plan |
| sl-code-review | sl.review, sl.build |
| sl-security-audit | sl.audit, sl.review |
| sl-feature-discovery | sl.new, sl.plan |
| sl-feature-specification | sl.new |
| sl-doc-schemas | sl.new, sl.design, sl.brainstorm, sl.audit, sl.plan, sl.build, sl.autopilot, sl.hotfix, sl.done, sl.pull-request, sl.init, sl.xray, sl.diagnose |
| sl-architecture-discovery | sl.audit, sl.xray |
| sl-ecosystem | add (loses full view), all commands that route to next steps |
| sl-investigation | sl.diagnose (primary), sl.hotfix (STEP 7.1 escalation), sl.review (STEP 5.1 ambiguous findings), sl.audit (STEP 7.1 ambiguous findings) |
| sl-id-convention | sl.plan, sl.build, sl.hotfix, sl.done, sl.pull-request (all ID allocation and branch naming) |
| sl-tasks-checklist | sl.plan, sl.build, sl.autopilot (tasks.md schema and tick rules) |

## Main Flows

| Flow | Sequence | When to use |
|------|----------|-------------|
| Complete | brainstorm → new → design → plan → build → review → done | Complex features with UI |
| Standard | new → plan → build → review → done | Features without complex UI |
| Lean | new → build → done | Small changes, quick tasks |
| Autonomous | new → autopilot → done | Want zero-interaction implementation |
| Emergency | hotfix → done | Critical production bug |
| Exploration | brainstorm → new → ... | Don't know where to start |
| Triage | diagnose → (hotfix OR new OR no-action) | Vague symptom, unsure if bug/feature |
| New Project | init → build → done | Create new project/feature |
| Analysis | xray / audit | Check project health |

## Command Next-Steps Routing

Conditions evaluated top-to-bottom — use FIRST match.

| After | Condition | Suggest | Why |
|-------|-----------|---------|-----|
| sl.init | always | `/sl.new` | Onboarding done, start first feature |
| sl.brainstorm | idea ready to formalize | `/sl.new` | Capture as feature |
| sl.brainstorm | needs more exploration | continue brainstorm | Not ready to commit |
| sl.brainstorm | bug suspected, needs investigation | `/sl.diagnose` | Route to structured triage |
| sl.brainstorm | clear bug discovered | `/sl.hotfix` | Route to urgent fix |
| sl.diagnose | route=hotfix | `/sl.hotfix` | Confirmed bug requiring urgent fix |
| sl.diagnose | route=feature | `/sl.new` | Confirmed functional gap |
| sl.diagnose | route=extend | `/sl.new` or `/sl.plan` | Extend existing feature — load prior context |
| sl.diagnose | route=no-action | done | No real problem — stop here |
| sl.new | feature has complex UI (3+ screens) | `/sl.design` | UX spec needed before planning |
| sl.new | feature needs technical planning | `/sl.plan` | Architect before building |
| sl.new | feature is simple (1-2 files) | `/sl.build` | Skip planning, build directly |
| sl.new | user wants zero interaction | `/sl.autopilot` | Autonomous end-to-end |
| sl.design | always | `/sl.plan` or `/sl.build` | UX spec done, plan or implement |
| sl.plan | default | `/sl.build` | Most common path |
| sl.plan | user wants zero interaction | `/sl.autopilot` | Autonomous implementation |
| sl.build | mode=DEVELOPMENT, wants tests | `/sl.test` | Validate with automated tests |
| sl.build | mode=DEVELOPMENT, skip tests | `/sl.review` | Code review before merge |
| sl.build | mode=CORRECTION | `/sl.review` | Re-validate after fixes |
| sl.build | epic, more subfeatures pending | `/sl.build feature N` | Next subfeature in epic |
| sl.autopilot | always | `/sl.done` | Autopilot includes review; finalize |
| sl.test | tests passing | `/sl.review` | Validate code quality |
| sl.test | tests failing | fix + `/sl.test` | Iterate until green |
| sl.review | status=PASSED | `/sl.done` | All gates green, finalize |
| sl.review | status=BLOCKED | fix + `/sl.review` | Iterate until PASSED |
| sl.hotfix | always | `/sl.done` | Hotfix ready, finalize branch |
| sl.review | needs team review before merge | `/sl.pull-request` | PR for human review |
| sl.pull-request | PR open, awaiting review | wait for review | Human review pending |
| sl.pull-request | PR merged on GitHub | `/sl.done` | Cleanup local branch + tags |
| sl.pull-request | scope grew, need to update PR | `/sl.pull-request` | Idempotent — appends update section |
| sl.done | was feature, back on main | `/sl.new` | Start next feature |
| sl.done | was epic, more subfeatures | `/sl.build feature N` | Next subfeature |
| sl.done | was hotfix | `/sl.new` | Return to feature work |
| sl.ux | within active feature | return to current flow | UX applied, resume workflow |
| sl.ux | standalone | done | One-off UX task |
| sl.xray | issues found | `/sl.audit` | Deep health check |
| sl.xray | context mapped, ready to build | `/sl.new` | Start building with context |
| sl.xray | standalone analysis | done | Analysis delivered |
| sl.audit | critical issues found | `/sl.new` per issue | Create features to fix findings |
| sl.audit | project healthy | done | No action needed |
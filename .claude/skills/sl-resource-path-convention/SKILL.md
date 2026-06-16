---
name: sl-resource-path-convention
description: Use when writing commands or skills that reference other commands, skills, or scripts — ensures paths resolve correctly across all providers after installation
---

# Resource Path Convention

Commands and skills in `framwork/.codesl/` are the source of truth. After build, they are placed in provider-specific directories (`.claude/commands/`, `.agents/skills/`, `.gemini/commands/`, etc.). Hardcoded `.codesl/commands/` or `.codesl/skills/` paths break because these directories do not exist in the installed project. Use build-time variables to reference resources.

## When to Use

- Writing a command that references another command (e.g., autopilot loading sl.plan)
- Writing a command or skill that references a skill file
- Reviewing existing commands/skills for broken path references
- Creating new commands via `/sl.make`

## When NOT to Use

- Referencing scripts (`.codesl/scripts/*.sh` is always correct — fixed path)
- Referencing project files outside the framework (`docs/`, `src/`, etc.)
- Writing code in `build.js` or `cli/` (these operate on the build/install pipeline, not agent runtime)

## Variables

Build-time variables are available. `build.js` replaces them with the correct provider path during build.

### `.claude/commands/NAME.md`

Resolves to the full path of a command file for the target provider.

```
.claude/commands/sl.plan.md

# Claude → .claude/commands/sl.plan.md
# Gemini → .gemini/commands/sl.plan.toml
```

### `.claude/skills/NAME/FILE`

Resolves to the full path of a skill file. Use `SKILL.md` for the main file, or any sub-file name.

```
.claude/skills/sl-backend-development/SKILL.md

# Claude → .claude/skills/sl-backend-development/SKILL.md
# Gemini → .gemini/skills/sl-backend-development/SKILL.md
```

### Scripts (no variable needed)

Scripts are always at `.codesl/scripts/`. Use the literal path.

```
bash .codesl/scripts/status.sh
bash .codesl/scripts/done.sh
```

### `.codesl/X`

Resolves to the literal `.codesl/X` path — same across all providers. Use for **runtime paths** that exist in the user's installed project (the installer preserves `.codesl/`), but are NOT distributed by the build pipeline.

Typical cases: skills generated at runtime by commands like `/sl.xray` (which writes `project-patterns/`), the manifest file, or any artefact materialized in the user's project after install.

```
.codesl/skills/project-patterns/backend.md  # → .codesl/skills/project-patterns/backend.md
.codesl/manifest.json                       # → .codesl/manifest.json
```

**When to use `{{addpath:}}` vs `{{skill:}}`:**

| | `.claude/skills/NAME/FILE` | `.codesl/skills/NAME/FILE` |
|---|---|---|
| Skill exists in `framwork/.codesl/skills/` (source) | ✅ | ❌ |
| Skill is generated at runtime in user project | ❌ | ✅ |
| Resolves per-provider | ✅ | ❌ (always `.codesl/`) |

## Examples

### Correct

```markdown
## STEP 1: Load Context
1. Read .claude/commands/sl.plan.md — PRIMARY reference
2. Run: bash .codesl/scripts/status.sh
3. Read .claude/skills/sl-backend-development/SKILL.md
4. For components, Grep .claude/skills/sl-ux-design/shadcn-docs.md
```

### Incorrect

```markdown
## STEP 1: Load Context
Read .codesl/commands/sl.plan.md          ← BROKEN: doesn't exist after install
cat .codesl/skills/backend-development/SKILL.md  ← BROKEN: wrong path
bash .codesl/scripts/status.sh             ← CORRECT: scripts are at .codesl/
```

## Validation Checklist

```
[ ] No raw references to .codesl/commands/ (use .claude/commands/NAME.md)
[ ] No raw references to .codesl/skills/ (use .claude/skills/NAME/FILE for source skills, .codesl/skills/NAME/FILE for runtime-generated skills)
[ ] Script references use .codesl/scripts/ (literal, no variable)
[ ] Runtime artefacts in installed project use .codesl/X
[ ] Command names match provider-map.json commands keys
[ ] Skill names match provider-map.json skills keys (with sl- prefix)
[ ] Skill sub-files exist in the source skill directory
```
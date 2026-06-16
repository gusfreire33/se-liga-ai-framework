# Método "Se Liga AI" (`sl`)

Clone rebrandeado do método **code-addiction v0.4.0** (prefixo original `add`),
preparado para rodar em **4 CLIs**: Claude Code, Codex, Grok Build e Antigravity.

Tudo que era `add` virou `sl`; o runtime `.codeadd/` virou `.codesl/`.

## Estrutura

```
AGENTS.md         Instruções globais (lido por Codex, Grok e Antigravity)
README.md         Este arquivo

.claude/          Claude Code CLI
  commands/       17 comandos  (/sl, /sl.plan, /sl.build, ...)
  skills/         32 skills    (sl-planning, sl-ux-design, ...)
  agents/         9 subagentes

.codex/           Codex CLI
  skills/         32 skills    (padrão SKILL.md, cross-agent)
  prompts/        17 prompts   (/prompts:sl.plan, /prompts:sl.build, ...)

.grok/            Grok Build CLI
  skills/         49 skills    (32 conhecimento + 17 comandos-como-skill)

.agent/           Antigravity CLI (escopo de projeto)
  skills/         49 skills
.agents/          Antigravity UI (escopo de projeto)
  skills/         49 skills

.codesl/          Runtime compartilhado por TODOS os CLIs
  scripts/        12 scripts .sh (status.sh, done.sh, next-id.sh, ...) + testes
  fragments/      fragmentos de comando (tdd, startup-test)
  templates/      templates de docs
  manifest.json   registro de referência
```

## Por que cada CLI tem um formato diferente

`SKILL.md` é um **padrão cross-agent** — a mesma skill roda em Claude, Codex, Grok e
Antigravity sem mudar nada. O que difere é **onde** ficam e **como os comandos** são expostos:

| CLI | Skills | Comandos (workflows) | Instruções |
|-----|--------|----------------------|------------|
| **Claude Code** | `.claude/skills/` | `.claude/commands/sl.*.md` → `/sl.plan` | `CLAUDE.md` |
| **Codex** | `.codex/skills/` | `.codex/prompts/sl.*.md` → `/prompts:sl.plan` | `AGENTS.md` |
| **Grok Build** | `.grok/skills/` | skills `sl-plan`, `sl-build`... (slash de skill) | `AGENTS.md` |
| **Antigravity** | `.agent/skills/` (CLI) · `.agents/skills/` (UI) | idem Grok | `AGENTS.md` |

> Em Grok/Antigravity cada comando vira uma **skill** (ex.: comando `/sl.plan` → skill
> `sl-plan`), porque esses CLIs usam skills como mecanismo de slash command.

## Instalação rápida (uma linha)

> Repo: **[gusfreire33/se-liga-ai-framework](https://github.com/gusfreire33/se-liga-ai-framework)**.
> O instalador detecta os CLIs presentes e instala em todos (skills/comandos/runtime).

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.ps1 | iex
```

**macOS (Apple Silicon — M1/M2/M3/M4):**
```bash
curl -fsSL https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.sh | bash
```

**macOS (Intel):**
```bash
curl -fsSL https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.sh | bash
```

> As duas linhas de macOS são idênticas **de propósito**: o instalador só copia
> arquivos (markdown + scripts shell), sem binários compilados — então funciona igual
> em Intel e Apple Silicon (e em Linux). A mesma linha serve para os três.

**Opções:** `--project` instala na pasta atual · `--global` (padrão) nos diretórios home
· `--cli "claude,codex"` limita os CLIs. (No Windows: `-Project`, `-Global`, `-Cli`.)
Para instalar a partir de uma cópia local sem baixar nada:
`SL_SOURCE=/caminho ./install.sh --project` (PS: `-Source`).

---

## Instalação manual (por projeto)

Copie a pasta do(s) CLI(s) que você usa + o runtime para a raiz do seu projeto:

```bash
# Claude Code
cp -r .claude .codesl  /caminho/do/projeto/

# Codex          (precisa de .codex/skills, .codex/prompts e AGENTS.md)
cp -r .codex .codesl AGENTS.md  /caminho/do/projeto/

# Grok Build
cp -r .grok .codesl AGENTS.md  /caminho/do/projeto/

# Antigravity (CLI)
cp -r .agent .codesl AGENTS.md  /caminho/do/projeto/
# Antigravity (UI): use .agents em vez de .agent
```

`.codesl/` é **obrigatório** em todos — os comandos chamam `.codesl/scripts/...`.

### Instalação global (opcional)

- **Claude Code:** `.claude/skills/*` → `~/.claude/skills/`, `.claude/commands/*` → `~/.claude/commands/`
- **Codex:** `.codex/skills/*` → `~/.codex/skills/`, `.codex/prompts/*` → `~/.codex/prompts/`
- **Grok:** `.grok/skills/*` → `~/.grok/skills/`
- **Antigravity (CLI):** `.agent/skills/*` → escopo de projeto, ou `~/.gemini/config/skills/` (global)

## Mapa do rebrand

| De (original) | Para (este clone) |
|---|---|
| `/add`, `/add.plan` | `/sl`, `/sl.plan` |
| skills `add-*` / comandos `add.*` | `sl-*` / `sl.*` |
| runtime `.codeadd/` | `.codesl/` |
| marca `ADD`, `add-pro`, `code-addiction-ecosystem` | `SL`, `sl-pro`, `sl-ecosystem` |

**Preservado de propósito:** `add-on`/`add-to-cart` (inglês/código), `git add`, `@add/...`
em exemplos, e o **tipo de log `add`** (`fix|enhance|refactor|add|remove|config`) usado
pelos scripts — é valor de domínio, não a marca.

## Limitações

1. **`manifest.json`** é referência: o conteúdo foi reescrito no rebrand, então os hashes
   SHA256 originais não batem mais (só o campo `providers` foi atualizado).
2. **Outros providers** do método original (cursor, windsurf, etc.) não foram gerados —
   o conteúdo deles não existia na máquina (só esqueletos vazios) e dependeria do build
   tool original.
3. **Independente:** por usar `.codesl/` (não `.codeadd/`), coexiste com o code-addiction
   original num mesmo projeto sem colidir.

## Origem (base v0.4.0)

`~/.claude/{skills,commands,agents}` · `~/.codeadd/{scripts,fragments,templates,manifest.json}`
· formatos de CLI conforme docs oficiais de Codex, Grok Build e Antigravity (jun/2026).

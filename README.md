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

## Instalação (uma linha, via `npx`)

> Pré-requisito: **Node.js ≥ 16**. O `npx` é cross-platform — **uma única linha** serve
> para Windows, macOS (Intel/Apple Silicon) e Linux (o Node cuida da diferença de SO).

```bash
npx se-liga-ai install
```

> Enquanto não publicado no npm, instale direto do GitHub (já funciona):
> ```bash
> npx github:gusfreire33/se-liga-ai-framework install
> ```

Isso instala **global** na sua máquina (skills/comandos em `~/.claude`, `~/.codex`,
`~/.grok`, `~/.gemini/config/skills`, `~/.agents` + runtime em `~/.codesl`), ficando
disponível em qualquer projeto. Depois, **dentro de cada projeto** que for usar os comandos:

```bash
npx se-liga-ai init      # cria .codesl/ no projeto
```

> Por que o `init`? Os comandos referenciam `.codesl/scripts/` por caminho **relativo ao
> projeto**, então cada repo precisa do runtime local (um comando, instantâneo).

**Opções:** `--project` instala TUDO na pasta atual (sem global) · `--cli claude,codex`
limita os CLIs. Ex.: `npx se-liga-ai install --project --cli claude`.

### Atualizar (uma linha)

Para puxar as **novidades do repositório** e atualizar a versão instalada na sua máquina:

```bash
npx se-liga-ai update
```

> Direto do GitHub (enquanto não publicado no npm):
> ```bash
> npx github:gusfreire33/se-liga-ai-framework update
> ```

O `update` **poda os arquivos antigos do framework** (skills `sl-*`, comandos `sl.*` e o
runtime `.codesl/`) e recopia a versão nova — refletindo até renomeações e remoções. **Não
toca** nas suas skills/agentes próprios (só mexe no que começa com `sl`). Aceita as mesmas
flags do install (`--project`, `--cli`). Em projetos que já usam o sl, rode também
`npx se-liga-ai init` para atualizar o `.codesl/` local.

### Alternativa: scripts shell (sem Node)

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.ps1 | iex
```
```bash
# macOS (Intel/Apple Silicon) e Linux
curl -fsSL https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.sh | bash
```

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

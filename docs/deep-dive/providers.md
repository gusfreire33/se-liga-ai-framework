# Providers (CLIs)

`SKILL.md` é um **padrão cross-agent**: a mesma skill roda em todos os CLIs sem mudar nada.
O que difere entre eles é **onde** as skills ficam e **como os comandos** são expostos.

| CLI | Skills | Comandos | Instruções |
|-----|--------|----------|------------|
| **Claude Code** | `.claude/skills/` | `.claude/commands/sl.*.md` → `/sl.plan` | `CLAUDE.md` |
| **Codex** | `.codex/skills/` | `.codex/prompts/sl.*.md` → `/prompts:sl.plan` | `AGENTS.md` |
| **Grok Build** | `.grok/skills/` | skills `sl-plan`, `sl-build`… (slash de skill) | `AGENTS.md` |
| **Antigravity** | `.agent/skills/` (CLI) · `.agents/skills/` (UI) | idem Grok | `AGENTS.md` |

## Como cada um carrega

- **Claude Code** — comandos em markdown (`/sl.x`), skills em `SKILL.md`, subagentes em `.claude/agents/`.
- **Codex** — comandos viram *custom prompts* (`/prompts:sl.x`); skills em `~/.codex/skills`; instruções globais em `AGENTS.md`.
- **Grok Build** — reconhece o formato de skill da Anthropic; skills aparecem como slash commands. Cada comando do método é exposto como a skill `sl-<x>`.
- **Antigravity** (ex-Gemini) — skills no escopo de projeto em `.agent/skills/` (CLI) e `.agents/skills/` (UI); global em `~/.gemini/config/skills/`.

## Por que os comandos viram skills em Grok/Antigravity

Esses CLIs usam **skills como mecanismo de slash command**, então cada workflow
(`/sl.plan`, `/sl.build`…) é empacotado como uma skill `sl-plan`, `sl-build` etc.
O conteúdo é o mesmo do comando — só muda o formato de invocação.

## Instruções globais (AGENTS.md)

Codex, Grok e Antigravity leem um `AGENTS.md` na raiz do projeto. Ele descreve o método,
aponta o gateway `sl` e documenta o runtime `.codesl/`. No Claude Code, o equivalente é o
`CLAUDE.md`.

::: info Cobertura
Hoje o framework empacota **Claude Code, Codex, Grok e Antigravity**. Outros alvos do
método original (cursor, windsurf, etc.) não estão incluídos — dependiam do build tool
original e não faziam parte deste pacote.
:::

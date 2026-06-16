# Método "Se Liga AI" (`sl`) — Instruções do agente

> Lido automaticamente por **Codex CLI**, **Grok Build CLI** e **Antigravity CLI**
> (via `AGENTS.md`). No Claude Code, o equivalente é `CLAUDE.md` + `.claude/`.

Este projeto usa o método **`sl`** — um sistema de desenvolvimento orientado por
comandos (workflows) + skills (conhecimento) + scripts (runtime determinístico).

## Como invocar

- **Gateway:** comece pela skill/comando **`sl`** — ele responde dúvidas, guia o fluxo
  e sugere o próximo passo. (Claude/Codex: `/sl`; Grok/Antigravity: skill `sl`.)
- **Skills** carregam automaticamente por correspondência semântica (campo `description`).
- **Runtime:** os comandos chamam scripts em `.codesl/scripts/` (ex.: `status.sh`,
  `next-id.sh`, `done.sh`). Esse diretório precisa existir na raiz do projeto.

## Fluxo padrão de uma feature

```
sl.init      → onboarding do projeto (docs/owner.md, docs/product.md)
sl.new       → descoberta + about.md (requisitos)
sl.plan      → plan.md (tarefas sequenciadas, mapeamento de arquivos)
sl.build     → implementação (dispatch de subagentes por área)
sl.review    → revisão com auto-correção até 100%
sl.done      → finalização, changelog e merge
```

Atalhos: `sl.hotfix` (correção urgente), `sl.autopilot` (plan→build→review autônomo),
`sl.audit` / `sl.xray` (auditoria e mapa de arquitetura), `sl.diagnose` (triagem).

## Convenções

- **Idioma:** responda no idioma do usuário; termos técnicos em inglês.
- **Git:** os comandos NÃO fazem `git add/commit/push` por conta própria —
  o `.codesl/scripts/done.sh` é o dono da sequência de merge.
- **IDs:** features/hotfix seguem `[NNNN][L]` (ver skill `sl-id-convention`).
- **Tipo de log `add`:** os scripts usam `fix|enhance|refactor|add|remove|config`
  como tipos de iteração — `add` aqui é valor de domínio, não a marca.

## Localização das skills por CLI

| CLI | Skills | Comandos |
|-----|--------|----------|
| Claude Code | `.claude/skills/` | `.claude/commands/sl.*.md` |
| Codex | `.codex/skills/` | `.codex/prompts/sl.*.md` (`/prompts:sl.x`) |
| Grok Build | `.grok/skills/` | comandos expostos como skills `sl-*` |
| Antigravity (CLI) | `.agent/skills/` | comandos expostos como skills `sl-*` |
| Antigravity (UI) | `.agents/skills/` | idem |

Runtime compartilhado por todos: `.codesl/`.

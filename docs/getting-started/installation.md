# Instalação

**Pré-requisito:** Node.js ≥ 16. O instalador é cross-platform — a **mesma linha** roda em
Windows, macOS (Intel/Apple Silicon) e Linux.

## Uma linha (via npx)

```bash
npx github:gusfreire33/se-liga-ai-framework install
```

::: tip Publicação no npm
Em breve com o nome curto `npx se-liga-ai install`. Enquanto isso, a forma acima
(direto do GitHub) instala exatamente o mesmo conteúdo.
:::

Isso instala **global** na sua máquina, deixando o método disponível em qualquer projeto:

| CLI | Skills | Comandos |
|-----|--------|----------|
| Claude Code | `~/.claude/skills` | `~/.claude/commands` |
| Codex | `~/.codex/skills` | `~/.codex/prompts` |
| Grok Build | `~/.grok/skills` | skills `sl-*` |
| Antigravity | `~/.gemini/config/skills` + `~/.agents/skills` | skills `sl-*` |

Runtime compartilhado vai para `~/.codesl`.

## Por projeto

Os comandos referenciam `.codesl/scripts/` por **caminho relativo ao projeto**. Então,
dentro de cada repositório que for usar o método:

```bash
npx github:gusfreire33/se-liga-ai-framework init
```

Isso cria `.codesl/` na raiz do projeto. Pronto — os comandos passam a encontrar os scripts.

## Atualizar

Para puxar as **novidades do repositório** e atualizar a versão instalada na sua máquina,
**uma linha**:

```bash
npx github:gusfreire33/se-liga-ai-framework update
```

::: tip Forma curta
Quando publicado no npm: `npx se-liga-ai update`.
:::

O `update` **poda os arquivos antigos do framework** (skills `sl-*`, comandos `sl.*` e o
runtime `.codesl/`) e recopia a versão nova — refletindo até renomeações e remoções. Ele
**não toca** nas suas skills e agentes próprios (só mexe no que começa com `sl`). Aceita as
mesmas flags do install (`--project`, `--cli`).

::: warning Runtime por projeto
Num projeto que já usa o sl, rode também `npx github:gusfreire33/se-liga-ai-framework init`
para atualizar o `.codesl/` local com os scripts novos.
:::

## Opções

```bash
# instala TUDO na pasta atual (sem global)
npx github:gusfreire33/se-liga-ai-framework install --project

# limita os CLIs (ex.: só Claude e Codex)
npx github:gusfreire33/se-liga-ai-framework install --cli claude,codex
```

::: warning PowerShell
No PowerShell, coloque o valor de `--cli` entre aspas: `--cli "claude,codex"`
(sem aspas, o PowerShell quebra a vírgula em array).
:::

## Alternativa: scripts shell (sem Node)

::: code-group
```powershell [Windows]
irm https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.ps1 | iex
```
```bash [macOS / Linux]
curl -fsSL https://raw.githubusercontent.com/gusfreire33/se-liga-ai-framework/main/install.sh | bash
```
:::

## Verificar

Abra um projeto no seu CLI e chame o **gateway**:

- Claude Code / Codex: `/sl`
- Grok / Antigravity: acione a skill **`sl`**

Se ele responder guiando o fluxo, está instalado. Siga para o [Quickstart](/getting-started/quickstart).

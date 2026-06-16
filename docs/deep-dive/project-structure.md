# Runtime & Estrutura

## O pacote do framework

```
.claude/          Claude Code — commands(18) · skills(33) · agents(10)
.codex/           Codex       — skills(33) · prompts(18)
.grok/            Grok Build  — skills(51 = 33 + 18 comandos-skill)
.agent/           Antigravity CLI — skills(51)
.agents/          Antigravity UI  — skills(51)
.codesl/          Runtime compartilhado (o "motor")
AGENTS.md         Instruções globais (Codex/Grok/Antigravity)
bin/cli.js        Instalador npx
```

## O runtime `.codesl/`

É o que dá **determinismo** ao método — o que não pode ficar a cargo do modelo.

```
.codesl/
  scripts/        status.sh · next-id.sh · done.sh · feature-pr.sh ·
                  get-branch-metadata.sh · pattern-search.sh ·
                  architecture-discover.sh · log-jsonl.sh · log-iteration.sh …
  fragments/      fragmentos de comando (tdd, startup-test)
  templates/      templates de docs (feature, hotfix)
  manifest.json   registro de referência
```

Os comandos chamam esses scripts por **caminho relativo** (`.codesl/scripts/status.sh`),
então cada projeto precisa do `.codesl/` na raiz — é o que o `init` faz.

::: tip Tipo de log `add`
Os scripts usam `fix|enhance|refactor|add|remove|config` como tipos de iteração. O `add`
aqui é **valor de domínio** (não a marca) — `status.sh` conta entradas `"type":"add"` para
detectar features concluídas.
:::

## Artefatos gerados num projeto

Conforme você usa os comandos, o método cria:

```
docs/
  owner.md, product.md          (sl.init)
  features/<NNNN>F-<slug>/
    about.md                    (sl.new)
    plan.md                     (sl.plan)
    tasks.md                    (sl.plan/build)
    decisions.jsonl             (log de decisões)
    iterations.jsonl            (log de iterações)
CHANGELOG / changelog           (sl.done)
```

IDs seguem `[NNNN][L]` (ver skill `sl-id-convention`): `F` feature, `H` hotfix, `CHG` chore.

## Independência

Por usar `.codesl/` (e não o `.codeadd/` do método original), o Se Liga AI **coexiste**
com o code-addiction no mesmo projeto sem colidir.

# Mapa do Ecossistema

Como comandos, skills, runtime e providers se conectam.

## Visão geral

```
        VOCÊ
         │  invoca
         ▼
   ┌───────────┐      carrega        ┌──────────────┐
   │  COMANDOS  │ ───────────────▶   │    SKILLS     │
   │  /sl.plan  │   por relevância    │  sl-planning  │
   │  /sl.build │                     │  sl-ux-design │
   │   …(17)    │                     │     …(32)     │
   └─────┬──────┘                     └──────────────┘
         │ chama (determinístico)
         ▼
   ┌───────────┐
   │  RUNTIME   │  .codesl/scripts  (status, IDs, changelog, merge)
   └───────────┘
         ▲
         │ empacotado por provider
   ┌─────┴───────────────────────────────────────┐
   │  Claude Code · Codex · Grok · Antigravity     │
   └───────────────────────────────────────────────┘
```

## As relações

- **Comando → Skill:** cada comando declara/aciona as skills que precisa. `/sl.plan` puxa
  `sl-planning`, `sl-feature-specification`, `sl-id-convention`; `/sl.review` puxa
  `sl-code-review`, `sl-security-audit`; e assim por diante.
- **Comando → Runtime:** operações que precisam ser repetíveis (descobrir o próximo ID,
  ler o status da feature, montar o changelog, fazer o merge) são scripts em `.codesl/`.
- **Skill → Skill:** skills se referenciam (ex.: `sl-frontend-architecture` aponta para
  `sl-frontend-development` e `sl-ux-design`).
- **Gateway `/sl`:** lê a skill `sl-ecosystem` (este mapa, em forma de dados) para responder
  "qual comando uso agora?".

## Ciclo de uma feature

```
sl.init ──▶ sl.new ──▶ sl.plan ──▶ sl.build ──▶ sl.review ──▶ sl.done
 owner/      about.md   plan.md     código       100% ok       changelog
 product                tasks.md    (subagentes)               + merge
```

Cada caixa lê e escreve artefatos em `docs/features/<id>/`, registrando decisões e
iterações em `.jsonl` — é isso que mantém o contexto entre sessões.

## Onde aprofundar

- [Comandos](/reference/commands) — os 17 pontos de entrada
- [Skills](/deep-dive/skills) — os 32 módulos de conhecimento
- [Runtime & Estrutura](/deep-dive/project-structure) — o motor `.codesl/`
- [Providers](/deep-dive/providers) — como cada CLI carrega tudo

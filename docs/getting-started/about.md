# Sobre

**Se Liga AI** é um framework *spec-driven* para assistentes de código com IA. Ele
padroniza o ciclo de desenvolvimento de features — da descoberta de requisitos ao merge —
em **comandos** (workflows), **skills** (conhecimento de domínio) e **scripts** (runtime
determinístico), funcionando no mesmo formato em vários CLIs.

> O método interno usa o prefixo **`sl`**: comandos como `/sl.plan`, skills como
> `sl-ux-design`, runtime em `.codesl/`.

## O problema que ele resolve

Assistentes de IA são ótimos gerando código, mas inconsistentes no **processo**: pulam
requisitos, não seguem convenções do projeto, perdem contexto entre sessões. O Se Liga AI
impõe um **fluxo repetível**:

```
requisitos (about.md) → plano (plan.md) → execução → revisão até 100% → entrega
```

Cada etapa é um comando; cada comando carrega as skills certas e chama scripts que
garantem o que não pode ficar a cargo do modelo (IDs de feature, status, changelog, merge).

## As três camadas

| Camada | O que é | Onde vive |
|--------|---------|-----------|
| **Comandos** | Pontos de entrada / workflows (`/sl.plan`, `/sl.build`…) | `.claude/commands`, `.codex/prompts`, skills nos demais |
| **Skills** | Conhecimento de domínio carregado por relevância | `<provider>/skills/sl-*` |
| **Runtime** | Scripts determinísticos (status, IDs, merge) | `.codesl/scripts` |

## Princípios

- **Spec-driven:** a documentação dirige o código, não o contrário.
- **Cross-agent:** `SKILL.md` é um padrão comum — a mesma skill roda em Claude, Codex,
  Grok e Antigravity sem modificação.
- **Determinístico onde importa:** o que precisa ser repetível vira script, não prompt.
- **Idioma do usuário:** responde no seu idioma; termos técnicos em inglês.

## Origem

O Se Liga AI é um clone rebrandeado do método **code-addiction v0.4.0**. Tudo que era
`add` virou `sl` e o runtime `.codeadd/` virou `.codesl/`, tornando-o independente e
coexistível com o original. Veja [Providers](/deep-dive/providers) e
[Runtime & Estrutura](/deep-dive/project-structure) para os detalhes.

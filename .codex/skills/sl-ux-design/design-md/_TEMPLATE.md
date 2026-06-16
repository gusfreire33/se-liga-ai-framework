---
version: alpha
name: <Product>-design-analysis
description: >
  2-4 frases densas capturando a "voltagem de marca": atmosfera, par de cores
  assinatura, voz tipográfica e o anchor de diferenciação. Escreva como se
  descrevesse a marca pra alguém que nunca a viu.
colors:
  # roles, não nomes de cor. Sempre hex. Cubra: primary(+active/disabled),
  # ink/body/muted (texto), hairline (bordas), canvas/surface-* (fundos claros
  # e escuros), on-primary/on-dark (texto sobre cor), accent-*, success/warning/error.
  primary: "#______"
  ink: "#______"
  body: "#______"
  muted: "#______"
  hairline: "#______"
  canvas: "#______"
  surface-card: "#______"
  surface-dark: "#______"
  on-primary: "#______"
  success: "#______"
  warning: "#______"
  error: "#______"
typography:
  # escala com fontFamily, fontSize(px), fontWeight, lineHeight, letterSpacing.
  display-xl: { fontFamily: "____, sans-serif", fontSize: 64px, fontWeight: 400, lineHeight: 1.05, letterSpacing: -1.5px }
  display-lg: { fontFamily: "____", fontSize: 48px, fontWeight: 500, lineHeight: 1.1, letterSpacing: -1px }
  body:       { fontFamily: "____", fontSize: 16px, fontWeight: 400, lineHeight: 1.6, letterSpacing: 0 }
---

# <Product> — Design System

## 1. Visual Theme & Atmosphere
Qual sensação a interface transmite (1 parágrafo) + o anchor de diferenciação:
"se removerem o logo, como reconhecer?".

## 2. Color Palette & Roles
Tabela: token → hex → quando usar. Separe luz/escuro. Defina o par assinatura.

## 3. Typography Rules
Famílias, escala, pesos, tracking. Regra de pareamento (display vs body).

## 4. Component Stylings
Botões (estados), inputs, cards, badges, tabelas, modais: raio, borda, sombra, padding.

## 5. Layout Principles
Grid, larguras máximas, espaçamento base, ritmo vertical, densidade.

## 6. Depth & Elevation
Sombras (níveis), uso de hairlines vs sombra, glass/blur (se houver).

## 7. Do's and Don'ts
Lista curta e específica do que respeita/quebra a identidade.

## 8. Responsive Behavior
Breakpoints, o que colapsa, comportamento mobile-first.

## 9. Agent Prompt Guide
Instrução pronta: "Construa X usando estes tokens. Priorize <anchor>. Evite <don'ts>."

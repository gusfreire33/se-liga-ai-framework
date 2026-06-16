# DESIGN.md — Token Specs (Fase 0 da sl-ux-design)

Specs de identidade visual concretos (cores hex, tipografia, componentes) usados como
**âncora visual** antes de codar UI. Origem: [voltagent/awesome-design-md](https://github.com/voltagent/awesome-design-md) (90k★).

## Exemplos vendorizados (tons diversos)

| Arquivo | Marca | Tom de referência |
|---------|-------|-------------------|
| `linear.md` | Linear | Near-black, minimal, software-craft, 1 acento lavanda |
| `stripe.md` | Stripe | Clean editorial fintech, gradientes sutis |
| `vercel.md` | Vercel | Dark dev-tool, alto contraste, mono |
| `supabase.md` | Supabase | SaaS dev, verde/escuro |

## Como usar

1. **Casar uma marca existente:** leia o `.md` correspondente e siga os tokens/seções.
2. **Gerar um novo:** copie `_TEMPLATE.md` e preencha a partir do produto do usuário
   (use a "Design Thinking Phase" da SKILL.md pra definir tom/anchor primeiro).
3. **Puxar mais marcas sob demanda** (catálogo de 70+): baixe o raw do repo:
   ```bash
   curl -fsS -o design-md/<marca>.md \
     https://raw.githubusercontent.com/voltagent/awesome-design-md/main/design-md/<marca>/DESIGN.md
   ```

## Catálogo completo disponível no repo

airbnb · airtable · apple · binance · bmw · bmw-m · bugatti · cal · claude · clay ·
clickhouse · cohere · coinbase · composio · cursor · elevenlabs · expo · ferrari · figma ·
framer · hashicorp · ibm · intercom · kraken · lamborghini · linear.app · lovable ·
mastercard · meta · minimax · mintlify · miro · mistral.ai · mongodb · nike · notion ·
nvidia · ollama · opencode.ai · pinterest · playstation · posthog · raycast · renault ·
replicate · resend · revolut · runwayml · sanity · sentry · shopify · slack · spacex ·
spotify · starbucks · stripe · superhuman · tesla · theverge · together.ai · uber ·
vercel · vodafone · voltagent · warp · webflow · wired · wise · x.ai · zapier

> Nome de pasta no repo às vezes tem sufixo (ex.: `linear.app`, `mistral.ai`, `x.ai`).

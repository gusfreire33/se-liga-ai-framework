# Fluxos

Combinações de comandos para diferentes tamanhos de trabalho. Escolha pelo contexto —
do mais completo ao mais enxuto.

## Completo

Para features grandes ou times que querem rastreabilidade total.

```text
/sl.init → /sl.new → /sl.plan → /sl.build → /sl.review → /sl.test → /sl.done
```
Onboarding, spec, plano, execução, revisão, testes e entrega documentada.

## Padrão

O dia a dia de uma feature bem definida (sem onboarding repetido).

```text
/sl.new → /sl.plan → /sl.build → /sl.review → /sl.done
```

## Enxuto (Lean)

Mudança pequena e clara, com qualidade garantida.

```text
/sl.plan → /sl.build → /sl.review
```

## Autônomo

Deixa o coordenador tocar plan → build → review sozinho.

```text
/sl.autopilot
```
Ideal quando o escopo já está claro e você quer o resultado com mínima interação.

## Emergência (Hotfix)

Bug em produção, sem cerimônia.

```text
/sl.diagnose → /sl.hotfix → /sl.done
```
`diagnose` confirma a rota; `hotfix` aplica a correção; `done` fecha com changelog.

---

## Como escolher

| Situação | Fluxo |
|----------|-------|
| Projeto novo, feature grande | Completo |
| Feature normal do backlog | Padrão |
| Ajuste pequeno e claro | Enxuto |
| Escopo definido, quer agilidade | Autônomo |
| Produção quebrada | Emergência |

Veja casos reais em [Cenários](/reference/scenarios).

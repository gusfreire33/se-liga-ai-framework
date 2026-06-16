import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'pt-BR',
  title: 'Se Liga AI',
  description: 'Framework spec-driven para assistentes de código com IA — comandos, skills e runtime para Claude Code, Codex, Grok e Antigravity.',
  // Vercel serve na raiz; GitHub Pages serve em /se-liga-ai-framework/.
  // DOCS_BASE permite override manual no build local.
  base: process.env.VERCEL ? '/' : (process.env.DOCS_BASE || '/se-liga-ai-framework/'),
  cleanUrls: true,
  lastUpdated: true,
  head: [
    ['meta', { name: 'theme-color', content: '#076e66' }],
    ['meta', { property: 'og:title', content: 'Se Liga AI — Framework' }],
    ['meta', { property: 'og:description', content: 'Método sl: comandos + skills + runtime multi-CLI.' }],
  ],
  themeConfig: {
    siteTitle: 'Se Liga AI',
    nav: [
      { text: 'Início', link: '/' },
      { text: 'Comandos', link: '/reference/commands' },
      { text: 'Fluxos', link: '/reference/flows' },
      { text: 'Skills', link: '/deep-dive/skills' },
      { text: 'v0.4.0', items: [
        { text: 'Repositório', link: 'https://github.com/gusfreire33/se-liga-ai-framework' },
        { text: 'Changelog', link: 'https://github.com/gusfreire33/se-liga-ai-framework/commits/main' },
      ]},
    ],
    sidebar: [
      {
        text: 'Começar',
        collapsed: false,
        items: [
          { text: 'Sobre', link: '/getting-started/about' },
          { text: 'Instalação', link: '/getting-started/installation' },
          { text: 'Quickstart', link: '/getting-started/quickstart' },
        ],
      },
      {
        text: 'Referência',
        collapsed: false,
        items: [
          { text: 'Comandos', link: '/reference/commands' },
          { text: 'Fluxos', link: '/reference/flows' },
          { text: 'Cenários', link: '/reference/scenarios' },
          { text: 'Exemplo: /sl.db (RLS)', link: '/reference/example-data-engineer' },
        ],
      },
      {
        text: 'Aprofundar',
        collapsed: false,
        items: [
          { text: 'Mapa do Ecossistema', link: '/deep-dive/ecosystem-map' },
          { text: 'Skills', link: '/deep-dive/skills' },
          { text: 'Providers (CLIs)', link: '/deep-dive/providers' },
          { text: 'Runtime & Estrutura', link: '/deep-dive/project-structure' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/gusfreire33/se-liga-ai-framework' },
    ],
    search: { provider: 'local' },
    outline: { level: [2, 3], label: 'Nesta página' },
    docFooter: { prev: 'Anterior', next: 'Próximo' },
    lastUpdatedText: 'Atualizado em',
    footer: {
      message: 'Método sl — clone rebrandeado do code-addiction v0.4.0.',
      copyright: 'Se Liga AI · MIT',
    },
  },
})

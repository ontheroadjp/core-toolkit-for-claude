import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Core Toolkit for Claude',
  description: 'A structured AI-driven development workflow for Claude Code',
  lang: 'en-US',

  head: [
    ['link', { rel: 'icon', href: '/logo.svg', type: 'image/svg+xml' }],
    ['link', {
      rel: 'stylesheet',
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css'
    }]
  ],

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Core Toolkit for Claude',

    nav: [
      { text: 'Guide', link: '/guide/' },
      { text: 'Developer', link: '/developer/' },
      { text: 'Concept', link: '/concept/' },
      {
        text: 'GitHub',
        link: 'https://github.com/ontheroadjp/core-toolkit-for-claude'
      }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'User Guide',
          items: [
            { text: 'Overview', link: '/guide/' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Configuration', link: '/guide/configuration' }
          ]
        }
      ],
      '/developer/': [
        {
          text: 'Developer',
          items: [
            { text: 'Overview', link: '/developer/' },
            { text: 'Specification', link: '/developer/specification' }
          ]
        }
      ],
      '/concept/': [
        {
          text: 'Concept',
          items: [
            { text: 'Design Concept', link: '/concept/' },
            { text: 'Policy', link: '/concept/policy' }
          ]
        }
      ]
    },

    socialLinks: [
      {
        icon: 'github',
        link: 'https://github.com/ontheroadjp/core-toolkit-for-claude'
      }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2025 ontheroadjp'
    },

    search: {
      provider: 'local'
    }
  }
})

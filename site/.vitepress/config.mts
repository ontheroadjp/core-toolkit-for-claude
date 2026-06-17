import { defineConfig } from 'vitepress'

export default defineConfig({
  base: '/core-toolkit-for-claude/',
  title: 'Core Toolkit for Claude',
  description: 'A structured AI-driven development workflow for Claude Code',

  head: [
    ['link', { rel: 'icon', href: '/logo.svg', type: 'image/svg+xml' }],
    ['link', {
      rel: 'stylesheet',
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css'
    }]
  ],

  locales: {
    root: {
      label: 'English',
      lang: 'en-US',
      themeConfig: {
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
        footer: {
          message: 'Released under the MIT License.',
          copyright: 'Copyright © 2025 ontheroadjp'
        }
      }
    },

    ja: {
      label: '日本語',
      lang: 'ja-JP',
      themeConfig: {
        nav: [
          { text: 'ガイド', link: '/ja/guide/' },
          { text: '開発者向け', link: '/ja/developer/' },
          { text: 'コンセプト', link: '/ja/concept/' },
          {
            text: 'GitHub',
            link: 'https://github.com/ontheroadjp/core-toolkit-for-claude'
          }
        ],
        sidebar: {
          '/ja/guide/': [
            {
              text: 'ユーザーガイド',
              items: [
                { text: '概要', link: '/ja/guide/' },
                { text: 'インストール', link: '/ja/guide/installation' },
                { text: '設定', link: '/ja/guide/configuration' }
              ]
            }
          ],
          '/ja/developer/': [
            {
              text: '開発者向け',
              items: [
                { text: '概要', link: '/ja/developer/' },
                { text: '仕様サマリ', link: '/ja/developer/specification' }
              ]
            }
          ],
          '/ja/concept/': [
            {
              text: 'コンセプト',
              items: [
                { text: '設計コンセプト', link: '/ja/concept/' },
                { text: 'ポリシー', link: '/ja/concept/policy' }
              ]
            }
          ]
        },
        footer: {
          message: 'MIT ライセンスのもとで公開されています。',
          copyright: 'Copyright © 2025 ontheroadjp'
        }
      }
    },

    zh: {
      label: '中文',
      lang: 'zh-CN',
      themeConfig: {
        nav: [
          { text: '指南', link: '/zh/guide/' },
          { text: '开发者', link: '/zh/developer/' },
          { text: '概念', link: '/zh/concept/' },
          {
            text: 'GitHub',
            link: 'https://github.com/ontheroadjp/core-toolkit-for-claude'
          }
        ],
        sidebar: {
          '/zh/guide/': [
            {
              text: '用户指南',
              items: [
                { text: '概述', link: '/zh/guide/' },
                { text: '安装', link: '/zh/guide/installation' },
                { text: '配置', link: '/zh/guide/configuration' }
              ]
            }
          ],
          '/zh/developer/': [
            {
              text: '开发者',
              items: [
                { text: '概述', link: '/zh/developer/' },
                { text: '规范摘要', link: '/zh/developer/specification' }
              ]
            }
          ],
          '/zh/concept/': [
            {
              text: '概念',
              items: [
                { text: '设计概念', link: '/zh/concept/' },
                { text: '方针', link: '/zh/concept/policy' }
              ]
            }
          ]
        },
        footer: {
          message: '基于 MIT 许可证发布。',
          copyright: 'Copyright © 2025 ontheroadjp'
        }
      }
    }
  },

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Core Toolkit for Claude',

    socialLinks: [
      {
        icon: 'github',
        link: 'https://github.com/ontheroadjp/core-toolkit-for-claude'
      }
    ],

    search: {
      provider: 'local'
    }
  }
})

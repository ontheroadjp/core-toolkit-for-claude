# Repository Structure

## 観測した構造

```text
core-toolkit-for-claude/
├── AGENTS.md                    # Codex CLI 向け AI 運用指示
├── CLAUDE.md                    # Claude Code 向け AI 運用指示
├── README.md                    # 人間向け概要、インストール、利用手順
├── install.sh                   # commands/hooks/skills symlink と hook settings 登録
├── setup_statusline.sh          # status line symlink と settings 登録
├── .github/workflows/deploy.yml # VitePress site を GitHub Pages へ deploy
├── commands/                    # Claude/Codex が読む Markdown command 仕様
├── docs/                        # /init-docs が管理する L0-L3 設計 docs
├── hooks/                       # Claude Code hook scripts
├── partials/                    # commands から Read される共通手順
├── scripts/                     # status line / token usage 表示 scripts
├── site/                        # VitePress documentation site
├── skills/                      # Codex skill wrappers
└── templates/                   # issue / PR / README templates
```

根拠: `rg --files -uu`, `.github/workflows/deploy.yml:1-53`, `site/package.json:1-14`

## ディレクトリ責務

### `commands/`

Claude Code / Codex CLI が読む Markdown command 仕様を置く。`work.md` が通常入口で、`task.md` と `patch.md` は `work.md` から Read される委譲先である。`docs-sync.md`、`init-docs.md`、`new-issue.md`、`review-resolve.md`、`coding-*.md` も同じ command 群として管理される。

根拠: `commands/work.md:1-4`, `commands/task.md:1-9`, `commands/patch.md:1-8`, `commands/new-issue.md:1-9`

### `skills/`

Codex 用 skill wrapper を置く。各 `SKILL.md` は対応する command markdown を Source of Truth として読むことを指示する。

根拠: `skills/init-docs/SKILL.md:1-14`, `skills/work/SKILL.md`

### `hooks/`

Claude Code hook scripts を置く。現在存在する hook は `auto-approve-readonly.sh`, `cleanup-session.sh`, `guard-destructive-cmd.sh`, `log-access-prompt.sh`, `log-access-stop.sh`, `log-access-tool.sh`, `log-token-usage.sh` の 7 本である。

根拠: `hooks/` 実体一覧, `install.sh:29-34`

### `templates/`

issue、PR、README scaffold の template を置く。commands は `~/.config/claude-code-kit/templates/*.md` を参照するため、運用上は `templates/` をその場所へ symlink する。

根拠: `templates/issue.md:1-25`, `templates/pr.md:1-32`, `commands/task.md:131-138`, `commands/new-issue.md:69-76`

### `partials/`

slash command ではない共通手順を置く。現在は commit 手順を `partials/git-commit.md` に集約している。

根拠: `partials/git-commit.md:1-15`, `commands/task.md:113-116`, `commands/patch.md:50-52`

### `docs/`

`/init-docs` が生成・更新する L0-L3 設計 docs と `docs/.ai/repo.profile.json` を置く。`primary_docs` は調査入口として `docs/L3_implementation/specification_summary.md` と `docs/L1_project/repository_structure.md` を指す。

根拠: `commands/init-docs.md:75-219`, `docs/.ai/repo.profile.json`

### `site/`

VitePress の公開サイトを置く。`site/package.json` に npm scripts と依存関係、`site/.vitepress/config.mts` に `locales` 設定（en / ja / zh）と navigation/sidebar/site metadata が定義される。コンテンツは `site/`（英語）・`site/ja/`（日本語）・`site/zh/`（中国語簡体字）に配置される。GitHub Actions は `site/` で `npm ci` と `npm run docs:build` を実行する。

根拠: `site/package.json:1-14`, `site/.vitepress/config.mts:1-185`, `.github/workflows/deploy.yml:24-42`

### `scripts/` と `setup_statusline.sh`

`setup_statusline.sh` は `scripts/statusline.sh` を `~/.claude/statusline.sh` に symlink し、`~/.claude/settings.json` に `statusLine` を追加する。`scripts/statusline.sh` は `jq` と `bc` を使って context / rate limit 情報を表示する。

根拠: `setup_statusline.sh:6-55`, `scripts/statusline.sh:10-83`

## デプロイ構成

| 対象 | source | target | 方法 | 根拠 |
|---|---|---|---|---|
| Claude commands | `commands/*.md` | `~/.claude/commands/*.md` | `install.sh` が symlink | `install.sh:15-20` |
| Codex commands | `commands/*.md` | `~/.codex/commands/*.md` | `install.sh` が symlink | `install.sh:22-27` |
| Claude hooks | `hooks/*.sh` | `~/.claude/hooks/*.sh` | `install.sh` が symlink | `install.sh:29-34` |
| Codex skills | `skills/*/` | `~/.codex/skills/*` | `install.sh` が symlink | `install.sh:36-41` |
| templates | `templates/` | `~/.config/claude-code-kit/templates/` | README 記載の手動 symlink | `README.md:40-47` |
| statusline | `scripts/statusline.sh` | `~/.claude/statusline.sh` | `setup_statusline.sh` が symlink | `setup_statusline.sh:6-28` |
| site | `site/.vitepress/dist` | GitHub Pages | GitHub Actions | `.github/workflows/deploy.yml:39-52` |

## 補足

`site/.vitepress/dist/` は `.gitignore` 対象の build output であり、source of truth ではない。根拠: `.gitignore:12-15`, `.github/workflows/deploy.yml:39-42`

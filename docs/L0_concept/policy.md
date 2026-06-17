# Policy

## 技術選定ポリシー

- コマンド仕様は Markdown で管理する。AI が `commands/*.md` を読んで実行するため、別 DSL は置かない。根拠: `commands/work.md:1-4`, `commands/task.md:1-9`
- Codex skill は `skills/*/SKILL.md` に置き、対応する `commands/*.md` を Source of Truth として読む薄いラッパーにする。根拠: `skills/init-docs/SKILL.md:1-14`
- Claude Code hooks と補助ツールは Bash で実装する。根拠: `hooks/*.sh`, `scripts/*.sh`, `install.sh:1-3`
- 公開サイトは `site/` 配下の VitePress と npm で管理する。根拠: `site/package.json:1-14`, `.github/workflows/deploy.yml:24-37`

## セキュリティ方針

- 破壊的 Bash 操作は `hooks/guard-destructive-cmd.sh` で Lv0/Lv1 に分類する。Lv0 は即時ブロック、Lv1 は AI 自動実行ではなくユーザー手動実行へ委譲する。根拠: `hooks/guard-destructive-cmd.sh:12-127`
- 読み取り専用操作とセッション承認済み操作のみ `hooks/auto-approve-readonly.sh` が自動承認する。根拠: `hooks/auto-approve-readonly.sh:73-181`
- セッション承認は Stop hook で削除し、次セッションへ持ち越さない。根拠: `hooks/cleanup-session.sh:1-7`
- コミット前に個人情報、IP アドレス、ドメイン名、絶対パスを diff から確認する。根拠: `partials/git-commit.md:31-40`

## 運用・性能方針

- hooks は Claude Code の通常操作を過度に妨げない。ログ書き込み失敗時も処理を継続する実装がある。根拠: `hooks/auto-approve-readonly.sh:15-22`, `hooks/log-access-stop.sh`, `hooks/log-token-usage.sh`
- VitePress サイトは CI で `site/` を working directory として `npm ci` と `npm run docs:build` を実行し、GitHub Pages へデプロイする。根拠: `.github/workflows/deploy.yml:31-52`
- `scripts/statusline.sh` は `jq` と `bc` を使って context 使用率を表示する。根拠: `scripts/statusline.sh:10-31`

## 禁止事項

| 禁止事項 | 理由 | 根拠 |
|---|---|---|
| `~/.claude/` へ実体ファイルを置く | symlink-only 原則と single source of truth を壊す | `README.md:21-38` |
| `/task` で `docs/*` を直接更新する | docs 同期は `/docs-sync` の責務 | `commands/task.md:5-9` |
| `/docs-sync` で L0 を通常更新する | L0 は意思決定記録であり git diff 追従対象ではない | `commands/docs-sync.md:86-88` |
| `git add -A` / `git add .` を使う | 意図しないファイルをコミットしやすい | `commands/init-docs.md:279-280`, `partials/git-commit.md:25-40` |
| AI が `git push --force` など不可逆な git 操作を自動実行する | 共有履歴・未追跡変更を破壊する可能性がある | `CLAUDE.md:55-61`, `hooks/guard-destructive-cmd.sh:90-126` |

## 整合性方針

`install.sh` が settings に登録する hook は、現在の `hooks/` 配下に存在する script のみとする。存在しない hook を設定に登録しない。

根拠: `install.sh:80-87`, `hooks/` 実体一覧

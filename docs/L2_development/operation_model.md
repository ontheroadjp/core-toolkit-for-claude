# Operation Model

## 初期化と同期の使い分け

- `/init-docs` は「現状分析 -> profile生成 -> docs生成 -> AGENTS更新」を行う重い初期化。
  - 根拠: `init-docs.md:16`, `init-docs.md:17`, `init-docs.md:20`, `init-docs.md:182`
- `/docs-sync` は差分追随専用で、HARD STOP 条件では `/init-docs` を要求する。
  - 根拠: `docs-sync.md:7`, `docs-sync.md:8`, `docs-sync.md:102`, `docs-sync.md:104`, `docs-sync.md:116`

## ゲート設計

- 多くのコマンドは `repo.profile.json` の存在を前提にしている。
  - 根拠: `task.md:50`, `fix.md:30`, `create-test.md:23`, `own-task.md:17`, `init-git.md:43`, `docs-sync.md:22`
- Git 管理下の前提を要求するコマンドがある。
  - 根拠: `task.md:134`, `own-task.md:23`, `git-clean.md:14`, `docs-sync.md:49`

## 開発運用上の注意点

- `task` は Phase 1/2 完了を履歴マーカーで管理する。
  - 根拠: `task.md:120`, `task.md:132`, `task.md:195`, `task.md:205`
- `git-clean` は不可逆操作をデフォルトで禁止する。
  - 根拠: `git-clean.md:6`, `git-clean.md:72`, `git-clean.md:137`
- `init-git` は `docs/` と `repo.profile.json` 不在時に停止する。
  - 根拠: `init-git.md:25`, `init-git.md:29`, `init-git.md:38`, `init-git.md:43`

## 実行コマンド定義（repo.profile.json 観点）

- 現時点の `repo.profile.json` は `commands` が空であり、run/build/test の確定コマンドは未登録。
  - 根拠: `repo.profile.json`
- コマンド実体の追加は `init-test` や将来の実装追加時に再観測して確定する。
  - 根拠: `init-test.md:19`, `init-test.md:27`, `init-test.md:36`, `init-docs.md:29`

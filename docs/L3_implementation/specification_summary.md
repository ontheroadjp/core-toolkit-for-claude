# Specification Summary

## 対象

このサマリは、ルートに存在する Slash Command 仕様ファイルの要点を、断定可能な事実のみで整理したもの。

## コマンド別仕様要約

1. `init-docs.md`
- 実態分析から docs 再構築までを担う初期化コマンド。
- `repo.profile.json` と docs/AGENTS の更新、Phase 2.5 検証を要求する。
- 根拠: `init-docs.md:17`, `init-docs.md:46`, `init-docs.md:65`, `init-docs.md:75`, `init-docs.md:182`

2. `docs-sync.md`
- docs の差分追随専用。全体再構築は禁止。
- HARD STOP 条件では `/init-docs` 要求で停止。
- 根拠: `docs-sync.md:7`, `docs-sync.md:29`, `docs-sync.md:102`, `docs-sync.md:116`

3. `task.md`
- 実装 -> docs追随 -> main 取り込みの4フェーズを定義。
- `repo.profile.json` と Git 状態をゲートに持つ。
- 根拠: `task.md:10`, `task.md:14`, `task.md:18`, `task.md:50`, `task.md:55`, `task.md:126`

4. `fix.md`
- バグ修正の再現/原因確定/最小修正/検証を要求。
- ゲートとして `repo.profile.json` とクリーンワークツリーを要求。
- 根拠: `fix.md:22`, `fix.md:23`, `fix.md:30`, `fix.md:35`, `fix.md:47`

5. `create-test.md`（見出しは `/task`）
- テストケース作成タスク向け4フェーズを定義。
- 実行前提に `repo.profile.json` とクリーンワークツリーを要求。
- 根拠: `create-test.md:1`, `create-test.md:21`, `create-test.md:23`, `create-test.md:28`, `create-test.md:43`

6. `init-test.md`
- 言語混在を前提にテスト入口コマンドを確定し、`repo.profile.json` へ反映する仕様。
- 観測ベースで `commands.*` を確定する方針を定義。
- 根拠: `init-test.md:8`, `init-test.md:19`, `init-test.md:27`, `init-test.md:36`, `init-test.md:54`

7. `test-balance.md`
- テスト不足の横断診断と `/task` 向けブリーフ生成を担う。
- 直接コード編集は行わない方針。
- 根拠: `test-balance.md:8`, `test-balance.md:12`, `test-balance.md:38`, `test-balance.md:149`

8. `init-git.md`
- Git/GitHub 初期化または既存Git整備を安全手順で行う仕様。
- 前提として `docs/` と `repo.profile.json` を要求。
- 根拠: `init-git.md:3`, `init-git.md:7`, `init-git.md:25`, `init-git.md:29`, `init-git.md:50`

9. `git-clean.md`
- 変更を失わずにワークツリーをクリーン化する運用仕様。
- commit/stash はユーザー選択前提。
- 根拠: `git-clean.md:3`, `git-clean.md:9`, `git-clean.md:23`, `git-clean.md:65`

10. `own-task.md`
- 実装を進めず、作業状態を `/task` 実行可能状態へ正規化する仕様。
- 非 main / clean / Phase 1 完了マーカーをゴールに定義。
- 根拠: `own-task.md:3`, `own-task.md:6`, `own-task.md:7`, `own-task.md:8`, `own-task.md:31`

11. `issue.md`
- 壁打ちから Issue 起票までを段階化した仕様。
- 起票は `gh` 利用を前提にする。
- 根拠: `issue.md:4`, `issue.md:11`, `issue.md:31`, `issue.md:53`

## 未確認事項

- ソースコード実体（`src/` 等）を前提とした実装仕様は未確認。
- CI 定義・実ジョブ・実行コマンドの実体は未確認。
- 確定に必要: `.github/workflows/**/*.yml`, 実装ディレクトリ, 実行定義ファイル（`package.json`, `pyproject.toml`, `Makefile` など）

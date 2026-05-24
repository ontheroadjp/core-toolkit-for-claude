# /patch

このファイルは `commands/work.md` から Read されることを前提とした、docs 変更を伴わない軽微な修正専用のワークフローです。ゲート確認・ルーティング判定・stash 管理は work.md が担います。

- issue 不要 / PR 不要 / docs-sync 不要
- branch + commit → ユーザーが main へマージ
- ドキュメント変更が必要になった場合は task フローへエスカレーションする

---

## ワークフロー

### Phase 2: 実行

#### Step 1. ブランチ作成
```bash
git checkout -b patch/<変更内容を表す slug>
```

#### Step 2. 変更を実施してコミット
- 変更を実施する（ユーザー確認不要）
- コミットは複数回でも可。各コミットで `~/.config/claude-code-kit/partials/git-commit.md` を Read し、その手順に従ってコミットする
    - パラメータ: `issue_number=none`, `allowed_types=[fix, refactor, chore, style, test, docs]`
    - 注: patch フローは新機能追加を行わないため `feat` は許可しない

---

### Phase 3: 報告

ユーザーに以下を報告する:

- 変更内容サマリ
- main へのマージ手順（ユーザーが実行）:
    ```bash
    git checkout main
    git merge --ff patch/<slug>
    git branch -d patch/<slug>
    ```

報告後、`git checkout main` で main に戻る。

---

## エスカレーション（patch → task）

Phase 2 の実行中に以下のいずれかになった場合、task フローに引き継ぐ:

- ユーザーから追加指示があり、ドキュメント変更が必要になった
- 変更を進めるうちにドキュメント変更が必要と判明した

**引き継ぎ手順:**
1. 現時点の変更をコミットする（未コミットの場合）
2. ユーザーに報告: 「ドキュメント変更が必要なため task フローに切り替えます」
3. `~/.config/claude-code-kit/templates/issue.md` をもとに issue のドラフトを作成する
    - 「/patch で実施済みの変更」と「追加スコープ（エスカレーション理由）」を必ず記載する
    - **issue のタイトル・本文は英語で記述する**
    - ユーザーに確認を取り、`gh issue create` で作成する
4. `commands/task.md` を Read し、Phase 1 Step 2（プラン策定）から継続する
    - ブランチは再利用する（`patch/<slug>` のまま進む）
    - ゲートは通過済みとして扱う
    - Step 1（現状調査）は完了済みとして扱う

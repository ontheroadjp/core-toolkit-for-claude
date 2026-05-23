# AGENTS.md

このファイルは AI 運用の起点となる情報をまとめる。Codex がこのリポジトリで作業する際はここを先に読む。

## このリポジトリについて

AI 向けのカスタムプロンプト（Markdown）のリポジトリ。
アクティブコマンドは 4 本（commands/task.md, commands/patch.md, commands/docs-sync.md, commands/init-docs.md）。
`~/.codex/prompts/` へのシンボリックリンクでグローバルデプロイされる。

## Custom Command の使い分け（AI 向けルール）

- **task.md**: ユーザーは常にこれを呼ぶ。内部でルーティング判定を行い、patch フローまたは task フローを実行する。
  - docs 変更不要 → patch フロー（issue/PR なし、branch + commit → ユーザーが ff-merge）
  - docs 変更あり → task フロー（issue 自動生成 → 実装 → ドラフト PR 作成 → docs-sync へ引き継ぎ）
- **patch.md**: ドキュメント変更を伴わない軽微な修正専用コマンド。直接呼ばれることは少なく、task.md 経由が基本。
- **docs-sync.md**: git diff を事実として docs を最小更新し、ドラフト PR を公開する。task フロー完了後に呼ぶ。HARD STOP 時は init-docs を要求して終了する。
- **init-docs.md**: リポジトリ実態の全体把握と設計ドキュメント再構築。重い初期化。docs-sync が説明不能になった時点でここに戻る。

## 重要な設計原則

- **symlink-only 原則**: `~/.codex/` 配下には実体ファイルを置かず、全て本リポジトリへの symlink とする。このリポジトリが single source of truth。
- ルーティング判定は単一質問: 「この変更で `docs/*` への追加・変更・削除が必要か？」
- issue は task フローのみ必須（patch フローには不要）
- task フローのコミット形式: `<type>(#<issue number>): <short description>` (Conventional Commits)
  - Example: `feat(#23): implement user auth endpoint`
- ワークスペースのクリーン化は stash で行う（破壊的操作禁止）
- git diff が事実。AI の要約・解釈は補助情報にとどめる

## テンプレートの場所

- `commands/templates/issue.md` → `~/.config/claude-code-kit/templates/issue.md` としても参照可能
- `commands/templates/pr.md` → `~/.config/claude-code-kit/templates/pr.md` としても参照可能

## このリポジトリへの変更作業

- run/build/test コマンドは存在しない（Markdown のみ）
- ファイルを編集・追加・削除する際は、必ず task を実行すること（/task が使えない場合は task プロンプトを参照）
- 変更後は `docs/` の更新が必要になることが多い（docs-sync を呼ぶ）
- シンボリックリンクは自動更新される（リンク先の実体を変更するだけでよい）

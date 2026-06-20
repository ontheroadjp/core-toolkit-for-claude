# /git-commit

このファイルはコミット作成手順を定義するスラッシュコマンドです。`commands/*.md` から `/git-commit` として呼び出されます。

## 呼び出しパラメータ

呼び出し側は以下を明示してください（テキストで指定する形でよい）:

- `issue_number`: 関連 issue 番号（例: `37`）。指定なしの場合は `none`
- `allowed_types`: 使用可能な Conventional Commits type のリスト（例: `feat, fix, refactor, chore, style, test, docs`）
- `fixed_message`: 完全に固定したいコミットメッセージ（例: `docs: sync documentation`）。指定された場合は type 選択をスキップし、このメッセージで commit する

`fixed_message` が指定されている場合、`issue_number` と `allowed_types` は無視してよい。

## 手順

### 1. ブランチ確認
```bash
git branch --show-current
```
現在のブランチが `main` の場合:
- `git branch` で非 main ブランチを1つ特定する
- `git checkout <そのブランチ>` で移動してからコミットを続行する

### 2. 状態の正規化（WIP commits の squash）

まず `wip:` commits が存在するかを確認する:

```bash
git log $(git merge-base HEAD main)..HEAD --format="%s"
```

出力に `wip:` で始まる行が含まれる場合、次を実行する:

```bash
git reset --soft $(git merge-base HEAD main)
```

これにより:
- HEAD が merge-base（ブランチ分岐点）に戻る
- index（staging area）はそのまま — WIP commits の全変更がステージ済みになる
- working tree は不変

`wip:` commits がない場合はこのステップをスキップする（後方互換）。

このステップは呼び出し元の状態に依存せず、**どのような状態で呼ばれても**正しく動作するための正規化である。

### 3. ステージ済み diff の取得
```bash
git diff --staged
```
ステージされている変更がない場合は、コミット対象を確認してユーザーに報告し、中止する。

### 4. コミット前チェック（必須）
取得した diff の内容に以下が含まれていないことを必ず確認する:

- 個人情報（メールアドレス・氏名・電話番号等）
- IP アドレス（例: `192.168.x.x`）
- ドメイン名（例: `example.com`）
- 絶対ファイルパス（OS のルートから始まるフルパス）

検出された場合: コミットを中止し、検出箇所をユーザーに報告して指示を仰ぐ。

### 5. コミットメッセージの決定

#### `fixed_message` が指定されている場合
そのまま commit する:
```bash
git commit -m "<fixed_message>"
```

#### `fixed_message` が指定されていない場合
5.1. `allowed_types` の中から、変更内容に最も合致する type を 1 つ選ぶ
5.2. 変更内容を要約した短い英語の説明文（命令形・小文字始まり推奨）を生成する
5.3. メッセージを組み立てる:
- `issue_number` が指定されている場合: `<type>(#<issue_number>): <description>`
  - 例: `feat(#23): implement user auth endpoint`
- `issue_number` が `none` の場合: `<type>: <description>`
  - 例: `refactor: simplify routing dispatch`

### 6. コミット実行
```bash
git commit -m "<生成したメッセージ>"
```

pre-commit フックが失敗した場合、コミットを中止し、ユーザーに以下の選択肢を提示して待機する:

1. `--no-verify` でコミット（フックをスキップ）
2. その他（フックの警告内容を確認・修正してから再試行、など）

## Conventional Commits types（参考）

呼び出し側で `allowed_types` を絞り込むためのリファレンス:

| type | 用途 |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `refactor` | 外部挙動を変えない内部改善 |
| `chore` | ビルド・補助ツール・依存関係などの雑務 |
| `style` | フォーマット・空白等、コード意味を変えない変更 |
| `test` | テストの追加・修正 |
| `docs` | ドキュメントのみの変更 |

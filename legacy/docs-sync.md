# docs-sync.md

あなたはこのリポジトリのドキュメントを「実装との差分に追随させる」ための軽量同期を行うAIエージェントです。
想像・憶測は禁止。すべての更新は必ずリポジトリ内の根拠（変更差分、ファイルパス、該当行、設定値、CI定義）に基づいて行ってください。
不明点は「未確認」と明示し、確定に必要な観測やファイルを提示してください。

このコマンドは /init-docs の代替ではありません。
全体再構築・再設計は行わず、「差分追随」に限定します。

---

## 目的
- 実装変更に伴う docs のズレを最小化する（差分追随）
- 重い /init-docs を頻繁に回さずに済む運用を実現する
- docs の再現性・信頼性を維持する

---

## 前提（必須ゲート）
- docs/ ディレクトリが存在すること
  - 存在しない場合：/init-docs を要求して終了（何も変更しない）
- repo.profile.json が存在すること
  - 存在しない場合：/init-docs を要求して終了（何も変更しない）
- ネットワークが必要な操作は行わない（CI 実行などは提案に留める）

---

## スコープ（厳守）
- 変更された領域に関係する docs のみを更新する
- docs 構造（L1/L2/L3）の再設計は禁止
- AGENTS.md の大改造は禁止（必要最小限の追記のみ）
- repo.profile.json は原則更新しない（更新条件に該当する場合のみ）

---

## 0. 事前ゲート
- docs/ が存在しない場合：/init-docs を要求して終了
- repo.profile.json が存在しない場合：/init-docs を要求して終了

---

## 1. 変更差分の取得（必須）
以下のいずれか、または複数を用いて差分を取得する。

- 作業ツリー差分：git diff
- staged 差分：git diff --staged
- 直近コミット差分：git show --name-only

.git/ が存在せず差分が取得できない場合は未確認として停止し、
/init-git または /init-docs を要求して終了する。

---

## 2. 影響範囲の特定（必須）
- 変更ファイルを領域で分類する
  - 例：frontend / backend / api / db / infra / config / tests / docs
- 「どの docs がこの領域を説明しているか」を
  既存 docs の参照関係（リンク・AGENTS.md・CURRENT.md 等）を根拠に特定する
- 根拠無しに「それっぽい docs」を更新対象にしてはいけない

---

## 3. 軽量更新（必須）
対象 docs に対して、以下の優先順位で最小更新を行う。

1. 事実の更新
   - パス、設定値、コマンド、型、エンドポイントなど
2. 手順の更新
   - setup / run / test 手順が変わった場合
3. 仕様サマリの追記
   - docs/L3_implementation/specification_summary.md は該当箇所のみ更新
   - 全体書き換えは禁止

---

## 4. repo.profile.json の更新条件（原則しない）
以下のいずれかに該当する場合のみ、差分更新を許可する。

- .github/workflows/**/*.yml が変更された
- package.json scripts / Makefile / pyproject.toml 等の実行定義が変更された
- lockfile が変更され、package_manager が変わる可能性がある

該当しない場合は repo.profile.json を更新してはいけない。

---

## 5. AGENTS.md の最小追記（必要時のみ）
- 新規 docs ファイルを追加した場合のみリンクを追記する
- Custom / Command の使い分け表は以下のみ更新可
  - コマンド追加
  - ファイル名変更

---

## 6. 自己検証（必須）
- 更新した docs の記述が、実ファイルパス・設定・コマンドと一致するか確認
- commands に言及した場合、repo.profile.json と矛盾しないか確認
- 矛盾があれば修正するか未確認事項に分離する

---

## 7. HARD STOP（/init-docs 要求条件）
以下のいずれか **1つでも該当した場合**、
docs-sync は **一切の更新を行わず即時終了**し、
/init-docs の実行を要求する。

- 新しい主要レイヤやトップレベル構造が追加・変更された疑いがある
  - 例：apps/、packages/、infra/、services/ など
- 起動経路・エントリポイントが変わった疑いがある
  - 例：app/、pages/、src/main.*、server.* の追加・移動
- 既存 docs の参照関係を根拠として辿れない
- 変更差分が広範で「局所更新」の前提が崩れている
- specification_summary.md の「該当箇所」が特定できない

### HARD STOP 時の出力（固定）
- HARD STOP: /init-docs を実行してください
- 理由：一行で簡潔に
- 根拠：差分ファイル一覧
- 影響：このまま docs-sync を続行すると docs が実装と乖離し、再現性が失われます
- 次のアクション：/init-docs

---

## 出力形式（固定）
A. ゲート結果（docs/・repo.profile.json）
B. 対象差分サマリ（変更ファイル一覧）
C. 影響範囲と更新対象 docs（根拠付き）
D. 更新内容（変更点・追加点）
E. repo.profile.json 更新有無（理由付き）
F. AGENTS.md 追記有無（理由付き）
G. 未確認事項（ある場合のみ）
H. HARD STOP 判定と次のアクション

---

## 絶対にやってはいけないこと
- 差分が無いのに docs を更新する
- 根拠無しに docs 全体を再構築する
- repo.profile.json を毎回更新する
- HARD STOP 条件を無視して続行する

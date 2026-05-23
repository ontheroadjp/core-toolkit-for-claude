# /refactor

あなたはこのリポジトリに対する
**構造的負債を特定し、安全かつ最小リスクで内部品質を改善するリファクタリング専用 AI エージェント**です。

本コマンドは他の `/command` を参照しません。
すべて自己完結します。

---

## 目的

- 外部仕様を変更せずに内部品質を向上させる
- 可読性・保守性・拡張性を改善する
- 技術的負債を計測し、優先順位を明示する
- 破壊的変更は禁止（承認がない限り）

---

## 基本原則

- 挙動変更は禁止
- 既存テストを壊さない
- テストがない箇所は先に安全網を作る
- 最小差分で段階的に進める
- main 直接作業は禁止
- 想像での最適化は禁止（必ず根拠を示す）

---

## 実行前提ゲート

### G-1: `repo.profile.json` が存在すること
存在しない場合は終了する。

### G-2: `.git` が存在すること
存在しない場合は終了する。

### G-3: 対象ブランチのワークスペースがクリーンであること

```bash
git status --porcelain
```

出力が空でない場合は終了する。

---

## ブランチ再開ルール（追加）

### R-1: 現在ブランチが `main` の場合
- 新規ブランチ `refactor/<short-slug>` を作成して開始する。

### R-2: 現在ブランチが `main` 以外の場合
- 現在ブランチ名が `refactor/` で始まり、かつ clean の場合は **再開** する。
- それ以外のブランチの場合は終了し、`refactor/<short-slug>` へ切り替えを促す。

### R-3: 既存再開時のガード
- 直近コミットに `[/refactor]` または `[/refactor:wip]` が存在しない場合は、
  「再開根拠不足」として新規ブランチ開始を提案する。

---

## 測定ルール（追加）

### M-1: 構造メトリクス（必須）
- ファイル長（LOC）
- 関数長
- 分岐数ベース複雑度（近似可）
- 重複コード（同一/類似ブロック）
- 依存方向（import 方向）

### M-2: 比較の記録形式
- 変更対象について **Before / After** を同一指標で示す。
- 数値は「推定」ではなく、実コマンド結果または静的解析結果から記載する。

### M-3: パフォーマンス検証（該当時）
- I/O 経路やループ、ポーリング、シリアライズ処理に触れた場合のみ必須。
- 最低限、以下のいずれかを実施:
  - 既存ベンチ/計測コマンド
  - 同一入力での実行時間比較（3回以上）
- 許容閾値:
  - 代表ケースの p50/p95 が **10% 超悪化** なら失敗扱い（要再設計）
- 該当しない場合は「非該当理由」を明記する。

---

## docs 同期ルール（追加）

### D-1: docs 更新が必須となる条件
- 次のいずれかに該当した場合、最小更新を実施する:
  - コマンド/実行手順の変更
  - 設定キー・既定値・挙動契約の変更
  - 開発/運用フローに影響するファイル構造変更

### D-2: 更新対象
- `docs/L2_development/*`（setup/run/test に影響する場合）
- `docs/L3_implementation/specification_summary.md`（仕様記述に影響する場合）
- `README.md`（利用者向け最短手順に影響する場合）

### D-3: 変更なし判定
- docs 更新不要と判断した場合は、最終報告に「不要の根拠」を記載する。

---

## Phase 1: 構造分析

### Step 1: コードメトリクス確認

- ファイル長
- 関数長
- ネスト深度
- 循環的複雑度（近似可）
- 重複コード
- 依存方向
- レイヤー違反

出力形式:

```text
Refactor Candidates
- File:
- Smell:
- Risk:
- Refactor Type:
- Priority:
```

### Step 2: アーキテクチャ整合性確認

- レイヤー分離
- 責務の分離
- 依存逆転
- 単一責任違反
- God Object
- Fat Controller
- Utility 汚染

---

## Phase 2: リファクタリング戦略策定（承認必須）

出力形式:

```text
Refactor Plan
- Target:
- Current Issue:
- Refactor Technique:
- Behavior Change Risk:
- Test Strategy:
- Rollback:
```

使用可能テクニック例:

- Extract Method
- Extract Class
- Introduce Interface
- Replace Conditional with Polymorphism
- Move Method
- Dependency Injection
- Split Module
- Remove Dead Code

承認なしに実装へ進まない。

---

## Phase 3: 作業ブランチ作成

ブランチ命名規則:

- `refactor/<short-slug>`

手順:

```bash
git checkout -b refactor/<slug>
```

main での作業は禁止。

---

## Phase 4: セーフティネット構築

テストが不足している場合:

- Characterization Test 追加
- 境界値テスト追加
- 既存バグの再現テスト

完了後:

```bash
git commit -m "[/refactor:wip] Safety net added"
```

---

## Phase 5: 段階的リファクタリング

ルール:

- 一度に一つの変更
- 各変更後にテスト実行
- 公開 API 変更禁止
- 外部 I/O 仕様変更禁止
- パフォーマンス悪化禁止（M-3 を適用）

コミット粒度:

```bash
git commit -m "[/refactor] <specific change>"
```

---

## Phase 6: 回帰検証

確認項目:

- 既存テスト全通過
- カバレッジ低下なし（取得可能な範囲で）
- ビルド成功
- 警告増加なし
- パフォーマンス劣化なし（該当時）

完了後:

```bash
git commit -m "[/refactor] Regression verified"
```

---

## Phase 7: main 取り込み

ガード:

- Safety net commit 存在
- Regression commit 存在
- 現在ブランチが `main` でない
- ワークスペースがクリーン

方法:

### A. ローカルマージ

```bash
git checkout main
git merge --no-ff refactor/<slug>
```

### B. PR 経由

PR 本文に含める:

- Before / After 構造比較
- メトリクス改善値
- 影響範囲
- 回帰確認結果
- docs 同期結果（更新有無・根拠）

---

## HARD STOP 条件

- テストが存在しないかつ安全網構築不可
- 挙動変更が不可避
- 依存関係が循環して分離不能
- 影響範囲が過大で段階的実行不可

その場合は終了する。

---

## 最終報告フォーマット

```text
A. Refactor Scope
B. Structural Issues
C. Implemented Changes
D. Test Coverage
E. Metric Improvements
F. Remaining Technical Debt
```

---

## 設計方針

- 他の /command に依存しない
- 挙動は変えない
- 品質を数値で示す
- 小さく刻んで安全に進める
- main を汚さない

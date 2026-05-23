# init-test.md（他言語対応版）

## 概要（Summary）

`init-test` は、リポジトリの **テスト環境の初期構築およびアップデート**を行い、
「ソースコード」と「テスト/ゲート（typecheck・lint等）」が継続的に釣り合う状態へ導くための基盤を整える。

対象言語は固定しない。TypeScript/JavaScript/Python/Shell などが **混在していても**、
観測可能な根拠に基づいて必要なゲートとテストを導入・確定し、実行できる状態にする。

---

## 前提（Non-negotiables）

- **想像・推測で判断しない**。観測可能な根拠（ファイル、設定、CI、実行ログ）に基づく。
- 既存のテスト基盤やCIは **破壊しない**。削除・大改造は禁止。
- 既に存在する `scripts.*` や設定は **尊重**する。上書きは最終手段。
- 変更は **差分最小**。必要最低限の導入のみ行う。
- `commands.*` は **一意に確定**し、`repo.profile.json` に反映する。
- 実行して「回る」ことを最重要とする（verify/test/typecheck/lint いずれか）。
- CI の追加/変更は原則 **ユーザー確認**が必要。

---

## 目的（Goals）

1. リポジトリで「回すべき入口コマンド」を確定する（`repo.profile.json` へ記録）。
2. 言語混在でも破綻しない最小のテスト/ゲート構成を導入する。
3. ローカルで実行し、成功/失敗を根拠付きで報告する。
4. 既存CIがある場合は整合性を確認し、必要ならユーザー確認の上で補正する。

---

## 出力（Outputs）

- `repo.profile.json` の更新（差分最小）
  - `commands.test`（必須）
  - `commands.typecheck`（該当言語が観測できる場合）
  - `commands.lint`（該当ツールが観測できる場合）
  - `commands.format`（該当ツールが観測できる場合）
  - `commands.verify`（可能なら推奨）
- 最小 smoke テスト（1〜3本）
- 実行結果ログ（何をどの順で実行し、何が成功/失敗したか）

---

## 全体フロー（Flow）

0. 事前確認（HARDSTOP条件判定）
1. 現状調査（言語/ツール/CIの観測）
2. テスト基盤の最小導入（既存尊重）
3. Static Gates（typecheck/lint/format 等）の最小導入（観測ベース）
4. smoke テスト作成（最小）
5. `commands.*` の確定と `repo.profile.json` 更新
6. ローカル検証（commands 実行）
7. CI 整合確認（存在する場合のみ。変更はユーザー確認）
8. 報告（固定フォーマット）

---

## 0. 事前確認（HARDSTOP条件）

以下に該当する場合は **実装に進まず停止**し、根拠と次の手を提示する。

- パッケージマネージャが不明で、依存導入手段が確定できない
- CI / スクリプト / 設定が複雑で、最小変更で整合を取れない
- テスト/ゲート導入に大規模な構造変更が必要
- 実行に必須の秘密情報が不足（例：.envが必要でローカル実行不可）

---

## 1. 現状調査（観測）

### 1.1 言語・実行系の観測（推測禁止）

#### TypeScript / JavaScript
- `package.json` の有無
- ロックファイルの有無（`pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`）
- `tsconfig.json` の有無
- `scripts` の有無（test/lint/typecheck/format 等）
- テストランナー設定（jest/vitest/mocha 等）

#### Python
- `pyproject.toml` / `poetry.lock` / `requirements*.txt` / `uv.lock`
- `pytest.ini` / `tox.ini` / `noxfile.py`
- `scripts` ではなく CLI（pytest/ruff/mypy 等）の入口があるか

#### Shell
- `scripts/`, `bin/`, `tools/` 配下の `.sh` や shebang
- 実行権限（+x）
- CI や `package.json` scripts / Makefile から参照されているか

### 1.2 既存テストの観測
- `tests/`, `__tests__/`, `test/` の存在
- `*.test.*`, `*.spec.*` の存在
- 既存 smoke 相当があるか

### 1.3 既存CIの観測（破壊禁止）
- `.github/workflows/*.yml` 等
- 既に test/lint/typecheck が走っているか
- Node/Python バージョンが固定されているか（`.nvmrc`, `engines`, `pyproject` 等）

---

## 2. テスト基盤の最小導入（既存尊重）

### 2.1 `commands.test` の確定（最優先）

以下の優先順位で `commands.test` を確定する（既存優先）。

1) `repo.profile.json` に既に `commands.test` がある → それを採用（変更しない）
2) `package.json scripts.test` がある → `npm|pnpm|yarn run test` を採用
3) Python で `pytest` 実行が観測できる → `pytest -q` 等を採用
4) 複数言語混在で入口が分散する場合 → `commands.verify` を主入口にし、`commands.test` は最も中核のテスト入口を指す（例：Node の test）

※ “中核” は観測根拠（CIで呼ばれている/READMEに書かれている/既存scriptsがある）で決める。

### 2.2 パッケージマネージャの決定（Nodeの場合）
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `package-lock.json` → npm
- それでも不明なら HARDSTOP（勝手に決めない）

---

## 3. Static Gates の最小導入（観測ベース）

ここでいう Static Gates は、実行テスト以外の「品質ゲート」。
導入は **既存尊重**、不足時は **最小導入**、不確実なら **提案＋停止**。

### 3.1 TypeScript: typecheck
#### 採用条件（観測ベース）
- `tsconfig.json` が存在
  または
- `package.json` に `typescript` が依存として存在
  または
- `.ts/.tsx` が実態として存在（node_modules 除外）かつ Node プロジェクトが成立

#### 導入/更新ルール
- `package.json scripts.typecheck` があれば採用（変更しない）
- 無ければ `typecheck` を追加（例：`tsc -p tsconfig.json --noEmit`）
- `tsconfig.json` が無い場合：
  - 原則 HARDSTOP（生成は事故りやすい）
  - 生成する場合はユーザー確認が必要（生成テンプレと想定環境を提示）

### 3.2 JavaScript: lint / format（存在する場合）
#### 採用条件（観測ベース）
- ESLint 設定（`eslint.config.*` / `.eslintrc*`）が存在
- Prettier 設定（`.prettierrc*` / `prettier.config.*`）が存在

#### 導入/更新ルール
- `scripts.lint` / `scripts.format` があれば採用
- 無ければ導入提案は可能だが、依存追加が必要なら原則停止（init-testでの依存追加は “最小” のみに限る）

### 3.3 Python: lint / typecheck（存在する場合）
#### 採用条件（観測ベース）
- `pytest` が観測できる → test入口として採用候補
- `ruff` 設定がある（pyproject内含む） → lint採用候補
- `mypy.ini` や `pyrightconfig.json` → typecheck採用候補

#### 導入/更新ルール
- 既に `pyproject.toml` / requirements にツールがあるなら、それに合わせて `commands.lint` / `commands.typecheck` を確定
- 無いツールを新規に増やす場合は慎重（依存追加が必要なら原則提案止まり）

### 3.4 Shell: shellcheck / shfmt（必須ではない）
#### “存在 = 必須” としない
Shell はユーティリティ用途も多いため、以下の条件を満たす場合のみゲート化する。

#### ゲート化条件（観測ベース）
- CI から実行されている
  または
- `package.json scripts` / Makefile などから参照されている
  または
- `scripts/` `bin/` `tools/` にあり実行権限が付いている（運用コード）

#### 導入/更新ルール
- `shellcheck` / `shfmt` が既に使われている（CIや設定で観測） → `commands.lint` / `commands.format` に統合または個別確定
- 新規導入は原則提案止まり（依存追加/インストールの問題があるため）

---

## 4. smoke テスト作成（最小）

目的は「環境が回る」ことの確認。網羅は狙わない。

- 新規作成は 1〜3 本まで
- 既存のテスト構造に合わせる（jest/vitest/pytest等）
- 可能なら “純ロジック” を選ぶ（I/O に依存しない）
- I/O 領域しかない場合は “最小スモーク” に留める（例：CLI `--help` が落ちない）

---

## 5. `commands.*` の確定と `repo.profile.json` 更新

### 5.1 `commands` に記録するもの
- `commands.test`（必須）
- `commands.typecheck`（該当言語/ツールが観測できる場合）
- `commands.lint`（該当ツールが観測できる場合）
- `commands.format`（該当ツールが観測できる場合）
- `commands.verify`（推奨）
  - `verify` は「存在するゲートだけ」を束ねた入口とする

### 5.2 `commands.verify` の原則
- 既に `verify` があるなら採用（変更しない）
- 無ければ、存在するものをこの順で束ねる（例）
  - typecheck → lint → test
- 混在リポジトリでは verify が最も価値が高い
  （ただし “複数エコシステムを横断する” ため、実行方法は根拠を必ず提示）

---

## 6. ローカル検証（必須）

以下を **可能な範囲で実行**し、成功/失敗を記録する。

- `commands.verify` がある → verify を実行
- verify がない → `commands.test` を実行
- 追加した `commands.typecheck` / `commands.lint` がある → 個別に実行（時間が許す範囲で）

※ 実行不能（秘密情報不足など）の場合は、理由を根拠付きで記録し、HARDSTOP か “未検証” として報告する。

---

## 7. CI 整合確認（存在する場合のみ）

### 7.1 既存CIがある場合
- 既存の test/lint/typecheck を削除しない
- ローカルの `commands.*` とCIの実行内容が矛盾していないか確認
- 矛盾がある場合は、どちらを正とするかを提案する（根拠：既存運用/README/CI）

### 7.2 CI 変更はユーザー確認が必要
- 新規ジョブ追加
- 実行コマンドの差し替え
- Node/Python バージョン固定の追加

---

## 8. 報告（固定フォーマット）

以下のフォーマットで出力する。

### A. 観測結果（Evidence）
- 検出した言語（TS/JS/Python/Shell 等）
- 根拠ファイル（例：package.json、tsconfig、pyproject、CI等）
- 既存のテスト/ゲートの有無

### B. 確定したコマンド（repo.profile.json）
- commands.test: ...
- commands.typecheck: ...（該当時）
- commands.lint: ...（該当時）
- commands.format: ...（該当時）
- commands.verify: ...（該当時）

### C. 変更内容（Diff summary）
- 追加/更新したファイル一覧
- `repo.profile.json` の差分概要
- 追加した smoke テストの説明（何を確認するか）

### D. 実行結果（Local run）
- 実行したコマンドと結果（成功/失敗）
- 失敗時はログの要点と次の手（最短ルート）

### E. CI 整合（CI exists の場合）
- CI が何を実行しているか
- ローカルとの差分
- 変更提案（ユーザー確認が必要なものを明示）

---

## 付記：運用上の位置づけ

- `init-test` は「基盤整備」コマンドであり、
  網羅的なテスト増殖を目的としない。
- ソースとテストの継続的バランス改善は `test-balance` が担う。
- `init-test` は「環境が回る」「入口が確定している」状態を提供する。


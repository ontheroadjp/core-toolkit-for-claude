# tests/README.md — L3 per-file doc

## 目的・役割

`tests/` ディレクトリの構成・テスト対象・実行方法を説明するドキュメント。

## 動作の概要

- `tests/hooks/test-approval-hooks.sh` が検証するテストカテゴリ一覧を表で提示
- 実行コマンドと終了コードの意味を記載
- 前提条件（依存ツール・実行環境）を明記

## 重要な設計判断

- テストは shell スクリプトで実装されており、外部テストフレームワーク不要
- 全テスト PASS で exit 0、FAIL があれば exit 1 とするシンプルな規約を明示

## 統合ポイント

- テスト対象: `hooks/auto-approve-readonly.sh`、`hooks/guard-destructive-cmd.sh`、`hooks/cleanup-session.sh`
- CI での実行は現時点では定義されていない（手動実行のみ）

根拠: `tests/README.md:1-50`, `tests/hooks/test-approval-hooks.sh:1-407`

# skills/README.md — L3 per-file doc

## 目的・役割

`skills/` ディレクトリの目的・skill wrapper の仕組み・`commands/` との対応関係を開発者向けに説明するドキュメント。

## 動作の概要

- skill が `commands/*.md` を Source of Truth として Read するだけの薄い wrapper であることを説明
- ディレクトリ構造（`<name>/SKILL.md` と `<name>/work` サブディレクトリ）を図示
- skill 一覧と対応コマンドの対照表を提示

## 重要な設計判断

- skill 側にはロジックを書かず、全て commands/ 側に集約するアーキテクチャを明示
- 新しいコマンドを追加した際の skill 追加手順を案内

## 統合ポイント

- 参照元: Codex CLI ユーザー、`install.sh`（symlink 作成）
- 関連: `skills/*/SKILL.md`（各 skill の実体）、`commands/*.md`

根拠: `skills/README.md:1-58`, `skills/work/SKILL.md:1-23`

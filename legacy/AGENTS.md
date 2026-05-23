# AGENTS.md

このファイルは、このリポジトリで AI が参照する最小の運用ガイドです。事実はリポジトリ内ファイルを根拠に判断してください（`init-docs.md:3`, `init-docs.md:4`, `init-docs.md:5`）。

## Custom / Command の使い分け（AI向けルール）

- init-docs.md: repo の実態把握と設計ドキュメント再構築。重い初期化。
- docs-sync.md: 実装差分に追随する軽量同期。HARD STOP 時は /init-docs を要求して終了する。

## Docs Root

- `docs/L1_project`
- `docs/L2_development`
- `docs/L3_implementation`

上記は `repo.profile.json` の `doc_roots` と一致させること。

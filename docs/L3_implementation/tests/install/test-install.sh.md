# test-install.sh specification

`tests/install/test-install.sh` は、現在の local installer contract を実装する `test-local-install.sh` への互換 entry point である。

根拠: `tests/install/test-install.sh:1-6`

`test-local-install.sh` は isolated HOME と temporary Git repository を使い、repository root 以外での拒否、Codex local assets、local hook settings、global Codex status line、toolkit 管理の旧 global Claude assets/status line の除去を検証する。

根拠: `tests/install/test-local-install.sh:1-34`

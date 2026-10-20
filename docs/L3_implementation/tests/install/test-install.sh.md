# test-install.sh specification

`tests/install/test-install.sh` は、現在の local installer contract を実装する `test-local-install.sh` への互換 entry point である。

根拠: `tests/install/test-install.sh:1-6`

`test-local-install.sh` は isolated HOME と temporary Git repository を使い、repository root 以外での拒否、Codex local assets、local hook settings、global Codex status line、toolkit 管理の旧 global Claude assets/status line の除去を検証する。

`.gitignore` については、末尾改行のない既存ファイルの保持、2回インストールしても各 entry と識別コメントが1件のままであること、Codex 導入後に `.codex/` が `git status` に現れないこと、Agy 選択で `.gitignore` が変わらないことを検証する。Claude では、旧 installer が共有 `.claude/settings.json` に登録した toolkit hook だけが除去されユーザー hook・permissions が残ること、hook が `.claude/settings.local.json` に登録され ignore されること、`.claude/` 全体を ignore 済みの repository には追記しないことを検証する。

根拠: `tests/install/test-local-install.sh:1-88`

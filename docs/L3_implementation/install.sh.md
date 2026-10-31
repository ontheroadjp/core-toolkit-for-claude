# install.sh

## 目的・役割

`install.sh` は、対象リポジトリの root で実行する対話式 installer である。Claude Code、Codex CLI、Agy のいずれかを選択し、agent 固有の repository-local assets と必要な global status line を設定する。

根拠: `install.sh:1-250`

## 動作概要

1. `git rev-parse --show-toplevel` と現在ディレクトリを照合し、Git repository root 以外では変更せず失敗する。
2. この toolkit を指す既存の global symlink、global hook registration、Claude/Codex の toolkit 管理 status line だけを除去する。認証情報、履歴、他者の設定は対象外である。
3. Claude を選ぶと `<project>/.claude/`、Codex を選ぶと `<project>/.codex/` に commands、hooks、hooks/lib、scripts、skills、templates の symlink を作る。
4. 生成した5ディレクトリと hook settings file（Claude: `.claude/settings.local.json`、Codex: `.codex/hooks.json`）を project の `.gitignore` に追記する。Agy は project-local 生成物がないため `.gitignore` を変更せず、メニューにもその旨を表示する。
5. Claude/Codex は `global/CLAUDE.md` の内容を、project root の `CLAUDE.md`（Claude）または `AGENTS.md`（Codex）へマーカー付きブロックとして書き込む。Agy は対象外である。
6. `jq` がある場合、project-local hook settings file へ hook registration を冪等に追加する。Claude は登録前に、旧 installer が共有 `.claude/settings.json` に書いた toolkit hook だけを除去する。
7. Claude/Codex は各 native status line setup script を実行する。Agy は `~/.local/bin/agy-rate-status` を `scripts/setup_statusline_for_agy.sh` へ symlink し、`~/.gemini/antigravity-cli/settings.json` の `statusLine` を command として設定する。

根拠: `install.sh:5-224`, `scripts/setup_statusline_for_claude.sh:1-57`, `scripts/setup_statusline_for_codex.sh:1-93`, `scripts/setup_statusline_for_agy.sh:1-28`

## 主要な判定ロジック

`remove_managed_link` は link target が toolkit root 配下である場合だけ global link を削除する。JSON の解除も、過去の global hook command prefix または Claude status-line command が toolkit 由来の既知値である場合だけ行う。Codex の status line は toolkit が設定する4項目を含むものだけを解除する。

`add_hook` は event 内に同じ command があるとき再登録しない。Claude hook command は実行時の `$CLAUDE_PROJECT_DIR` を使用し、Codex hook command は repository root からの `.codex/...` 相対 path を使用する。

`ensure_gitignore_entries` は追記前に、同一行が既に `.gitignore` にある場合と `git check-ignore` が対象 path を ignore 済みと判定する場合（例: `.claude/` 全体を ignore 済み）をスキップする。既存の行は変更せず、末尾改行がなければ補ってから追記し、識別コメント `# core-toolkit-for-claude (install.sh)` は最初の追記時に1回だけ書く。

Claude の hook 登録先を共有 `settings.json` ではなく `settings.local.json` にするのは、symlink 先の absolute path に依存するマシン固有の登録をチームで共有される設定から分離し、ignore 可能にするためである。ユーザー所有の `.claude/settings.json` は ignore しない。旧登録の除去は command prefix `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/` に一致する entry に限定し、二重実行を防ぐ。除去後に空になった event 配列は残る。

`ensure_agent_instructions` は `<!-- BEGIN/END core-toolkit-for-claude (install.sh) -->` で囲んだブロックを管理する。対象ファイルが無ければ新規作成し、マーカーがあればその区間だけを `global/CLAUDE.md` の最新内容に置換し、マーカーがない既存ファイルには空行を挟んで末尾に追記する（既存内容は変更しない）。書き込みは `mv` ではなく `cat > file` で行い、`AGENTS.md -> CLAUDE.md` のような symlink を壊さない。これらのファイルはユーザーが commit する project 資産のため `.gitignore` には追加しない。

根拠: `install.sh:24-46`, `install.sh:109-172`, `install.sh:174-225`

## 統合ポイント

- Claude local assets: `<project>/.claude/`（hook settings: `.claude/settings.local.json`）
- Codex local assets: `<project>/.codex/`（hook settings: `.codex/hooks.json`）
- agent instructions source: `global/CLAUDE.md`、出力: `<project>/CLAUDE.md` / `<project>/AGENTS.md`
- project ignore rules: `<project>/.gitignore`
- Claude global status line: `~/.claude/statusline.sh`, `~/.claude/settings.json`
- Codex global status line: `~/.codex/config.toml`
- Agy global status command: `~/.local/bin/agy-rate-status`
- regression test: `tests/install/test-local-install.sh`

## 検証

```bash
bash tests/install/test-local-install.sh
bash tests/install/test-setup-statusline-for-codex.sh
shellcheck -x install.sh scripts/setup_statusline_for_agy.sh tests/install/test-local-install.sh
```

## 変更履歴（git log より自動生成）

- ee19232 feat(#418): ignore installed toolkit assets in the project .gitignore
- 4e52078 feat: install agent assets per project (#417)
- 0bfdaf3 #372 Move status line setup scripts into scripts directory (#373)
- 3fa2055 #370 Add idempotent Codex status line setup (#371)
- 396533d #367 Automate CLAUDE.md/AGENTS.md global symlinks in install.sh (#368)
- d5359f7 #340 Approve Codex permission requests (#341)
- 4f4aab8 #324 Install the worktree linker for consumer repositories (#325)
- e7d5698 fix(#316): resolve session paths via hooks/lib/session-paths.sh to survive worktree-isolated harness guard
- 214011d fix: correct keybindings.json symlink path in install.sh
- 25a8151 fix: sync self-referential skill symlinks to .gitignore in install.sh

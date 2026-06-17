# インストール

> **symlink-only 原則:** `~/.claude/` 配下に置くファイルは全てこのリポジトリへのシンボリックリンクとし、実体ファイルは置かないこと。このリポジトリが single source of truth。`~/.claude/` は参照ポイントに過ぎない。

## クイックインストール

最も簡単なセットアップ方法:

```bash
git clone https://github.com/ontheroadjp/core-toolkit-for-claude.git
cd core-toolkit-for-claude
./install.sh
```

以下のシンボリックリンクが作成されます:
- `commands/*.md` → `~/.claude/commands/` および `~/.codex/commands/`
- `hooks/*.sh` → `~/.claude/hooks/`
- `skills/*/` → `~/.codex/skills/`

対象ディレクトリは自動で作成されます。

## 手動セットアップ

### Step 0: 共有テンプレートのシンボリックリンク作成（必須）

```bash
mkdir -p ~/.config/claude-code-kit
ln -s /path/to/core-toolkit-for-claude/templates \
      ~/.config/claude-code-kit/templates
```

テンプレートは `~/.config/claude-code-kit/templates/` に置くことで、Claude Code と Codex CLI の両方から単一の場所で参照できます。

### Step 1: コマンドのシンボリックリンク作成（グローバル — 全リポジトリ）

```bash
ln -s /path/to/core-toolkit-for-claude/commands/work.md            ~/.claude/commands/work.md
ln -s /path/to/core-toolkit-for-claude/commands/task.md            ~/.claude/commands/task.md
ln -s /path/to/core-toolkit-for-claude/commands/patch.md           ~/.claude/commands/patch.md
ln -s /path/to/core-toolkit-for-claude/commands/docs-sync.md       ~/.claude/commands/docs-sync.md
ln -s /path/to/core-toolkit-for-claude/commands/init-docs.md       ~/.claude/commands/init-docs.md
ln -s /path/to/core-toolkit-for-claude/commands/review-resolve.md  ~/.claude/commands/review-resolve.md
ln -s /path/to/core-toolkit-for-claude/commands/new-issue.md       ~/.claude/commands/new-issue.md
```

これで `/work`、`/task`、`/patch`、`/docs-sync`、`/init-docs`、`/review-resolve`、`/new-issue` が全ての Claude Code セッションで利用できるようになります。

### Step 2: CLAUDE.md のシンボリックリンク作成（グローバル — 全リポジトリ）

```bash
ln -s /path/to/core-toolkit-for-claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Claude Code は全セッションで `~/.claude/CLAUDE.md` を自動読み込みするため、AI 運用指示が全リポジトリに適用されます。リポジトリ固有の指示が必要な場合はルートに `CLAUDE.md` を置いてください（ローカルがグローバルより優先されます）。

### Step 3: hooks のシンボリックリンク作成（任意）

```bash
mkdir -p ~/.claude/hooks
ln -s /path/to/core-toolkit-for-claude/hooks/auto-approve-readonly.sh \
      ~/.claude/hooks/auto-approve-readonly.sh
ln -s /path/to/core-toolkit-for-claude/hooks/guard-destructive-cmd.sh \
      ~/.claude/hooks/guard-destructive-cmd.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-token-usage.sh \
      ~/.claude/hooks/log-token-usage.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-prompt.sh \
      ~/.claude/hooks/log-access-prompt.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-tool.sh \
      ~/.claude/hooks/log-access-tool.sh
ln -s /path/to/core-toolkit-for-claude/hooks/log-access-stop.sh \
      ~/.claude/hooks/log-access-stop.sh
ln -s /path/to/core-toolkit-for-claude/hooks/cleanup-session.sh \
      ~/.claude/hooks/cleanup-session.sh
```

`~/.claude/settings.json` への hooks 登録は[設定](./configuration)を参照してください。

### Step 4: ステータスライン（任意）

Claude Code のステータスバーにコンテキスト使用率とレート制限を表示します:

```bash
./setup_statusline.sh
```

Claude Code を再起動すると反映されます。

## 要件

- [Claude Code](https://claude.ai/code) のインストール
- Git と gh CLI のインストールおよび認証済みであること
- jq のインストール

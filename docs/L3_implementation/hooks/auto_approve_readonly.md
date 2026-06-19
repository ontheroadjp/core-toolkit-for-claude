# auto-approve-readonly hook specification

## 目的と安全境界

`hooks/auto-approve-readonly.sh` は Claude Code / Codex CLI の PreToolUse hook である。通常操作の不要な許可プロンプトを減らしつつ、自動承認を次の2種類に限定する。

1. 永続状態を変更しない読み取り専用操作
2. 現在セッションでユーザーが承認したファイルまたはツールカテゴリに属する操作

この分類に確信を持てない操作は出力なしで終了し、クライアントの通常許可フローへ戻す。破壊的操作は allowlist より先に評価し、session-approved が存在しても block する。

根拠: `docs/L0_concept/policy.md`, `hooks/auto-approve-readonly.sh:309-511`, `hooks/lib/approval-safety.sh`

## セッションと実行元の解決

session ID は次の優先順で解決し、英数字・`.`・`_`・`-` 以外を `_` に置換する。

1. `CLAUDE_CODE_KIT_SESSION_ID`
2. payload の `session_id`
3. payload の `transcript_path` を hash 化した ID
4. `CODEX_THREAD_ID` を hash 化した ID
5. `process-<PPID>` fallback

承認ファイルの既定値は `${XDG_STATE_HOME:-$HOME/.local/state}/claude-code-kit/sessions/<session-id>/session-approved`、一時領域の既定値は `/tmp/claude-code-kit/<session-id>/` である。process fallback 以外では承認ファイルの解決結果を `current-session-approved-path` に通知する。

Codex は hook の呼出しパスまたは `CODEX_MANAGED_BY_NPM`、`CODEX_MANAGED_BY_BUN`、`CODEX_CI`、`CODEX_THREAD_ID` で判定する。それ以外は Claude とする。

根拠: `hooks/auto-approve-readonly.sh:8-81`

## 判定順序

判定は次の順序で行う。後段の allowlist は前段の block / prompt 判定を上書きしない。

1. payload、session、agent、状態パスを解決する。
2. `Read` は常時承認する。
3. `Write` は session temp、承認ファイル自身、session-approved file の順に評価する。
4. `Edit` は session temp、session-approved file の順に評価する。
5. `Bash` 以外の未対応 tool は通常許可フローへ戻す。
6. `Bash` は共有 destructive guard を最初に評価する。
7. `/dev/null` redirect と escaped pipe を正規化する。
8. ファイルへの write redirect を検出した場合は通常許可フローへ戻す。
9. command を quote-aware に segment 分割する。
10. 全 segment が読み取り専用またはsession-approvedの場合のみ承認する。

根拠: `hooks/auto-approve-readonly.sh:309-511`

## File tool の許可

### Read

`Read` は入力パスに関係なく常時承認する。

### Write / Edit

次の場合のみ承認する。

- 正規化後のパスが `/tmp/claude-code-kit/<session-id>/` 配下にあり、temp root と session directory が symlink ではない
- `session-approved` に `file:<absolute-path>` として列挙されている
- `Write` 対象が現在の承認ファイル自身であり、初回作成、同一内容、または既存スコープを狭める変更である

承認ファイル自身へのスコープ追加は block する。その他の `Write` / `Edit` は通常許可フローへ戻す。

根拠: `hooks/auto-approve-readonly.sh:83-115`, `hooks/auto-approve-readonly.sh:249-380`

## Bash command の許可

### 常時許可する読み取り専用操作

| 分類 | 許可内容 | 主な除外 |
|---|---|---|
| Git | `status`, `log`, `diff`, `show`, `describe`, `rev-parse`, `ls-*`, `cat-file`, `blame`, `shortlog`, `stash list`, `worktree list` | `--output` |
| Git branch | 一覧・照会 mode | create/delete/move/copy/upstream変更 |
| Git remote | 一覧、`-v`, `show`, `get-url` | add/remove/rename/set-url/update |
| Git tag | 一覧・照会・verify mode | create/delete/sign/force |
| Git reflog | 一覧、`show`, `exists` | delete/expire |
| Git config | `--list`, `--get*`, `-l` | 値の設定・削除 |
| GitHub CLI | issue/PR/repository/release/run/workflow の list/view/status、`gh pr checks`、`gh auth status` | write action |
| Shell navigation / test | `cd`, `test`, `[ ... ]`, read-only `if` | command/process substitution、operatorを含む test |
| Unix read tools | `ls`, `cat`, `head`, `tail`, grep 系、`rg`, `fd`, `wc`, `cut`, `tr`, `sed`, `awk`, `sort`, `jq`, `yq`, `nl` など | 下記のwrite/execute mode |
| Runtime | version 表示 | script / program 実行 |
| curl | default GET / HEAD 相当 | custom method、data/form、upload、config、file output |
| npm | metadata照会、config取得、引数なしの `npm run` | script実行、publish、install、audit fix等 |

`git -C <directory>` は `-C` prefix を正規化した後、同じ Git 判定を適用する。

次の mode はコマンド名が読み取り系でも常時許可しない。

- `find -delete/-exec/-execdir/-ok/-fprint*`
- `sed -i/--in-place`
- `sort -o/--output`
- `yq -i/--inplace`
- `awk` の `system()`
- command を伴う `env`
- `date --set/-s`
- 値を指定する `hostname`
- `pytest`, `python -m pytest`

根拠: `hooks/auto-approve-readonly.sh:117-229`, `hooks/auto-approve-readonly.sh:411-495`

### session-approved tool category

`session-approved` に次の category がある場合だけ、対応する write action を承認する。

| category | 許可内容 | 除外 |
|---|---|---|
| `tool:git_write` | add, commit, merge, fetch, `pull --ff-only`, stash push/pop/apply, non-force push, branch checkout/switch, non-force branch operation | force push, pull without `--ff-only`, pull rebase/no-ff/force, checkoutによるpath復元, branch `-D` |
| `tool:gh_issue_write` | issue create/edit/close/delete/comment/reopen | その他 |
| `tool:gh_pr_write` | PR create/edit/close/comment/reopen/ready/review/checkout/merge | その他 |

destructive guard に該当する操作は category があっても block する。

根拠: `hooks/auto-approve-readonly.sh:267-306`, `hooks/lib/approval-safety.sh`

## 複合 command

newline、`;`、`|`、`||`、`&&` を引用符の外側だけで分割し、全 segment を個別評価する。single / double quote 内の `|` は正規表現等の文字として保持する。read-onlyな `if` / `then` / `else` / `fi` は各 body を個別評価する。

次は安全に分類せず通常許可フローへ戻す。

- 単独の background operator `&`
- command substitution `$()` / backtick
- process substitution `<()` / `>()`
- 未対応のshell構文
- 1つでも未許可のsegmentを含む複合command

根拠: `hooks/auto-approve-readonly.sh:128-229`, `hooks/auto-approve-readonly.sh:397-511`

## decision とログ

| 結果 | Claude | Codex |
|---|---|---|
| approve | `{"decision":"approve"}` | `{"decision":"allow"}` |
| prompt fallback | stdoutなし | stdoutなし |
| destructive block | reason付きblock JSON | reason付きblock JSON |

decision log は `logs/auto-approve/YYYY-MM.log` に次の形式で追記する。process fallback の session は `n/a` とする。

```text
[timestamp] agent=claude|codex session=<id|n/a> result=<result> tool=<tool> <detail>
```

根拠: `hooks/auto-approve-readonly.sh:64-75`, `hooks/auto-approve-readonly.sh:231-247`

## テストと既知の制限

`tests/hooks/test-approval-hooks.sh` は常時許可、session-approved、複合command、write mode、destructive block、session temp、cleanup をpositive / negativeの両面から検証する。

このhookは完全なshell parserではない。安全に分類できない構文を自動承認対象へ広げず、通常許可フローへ戻すことを互換動作とする。`apply_patch` 等の未対応toolや、任意コードを実行するbuild/test commandも自動承認しない。

根拠: `tests/hooks/test-approval-hooks.sh:1-274`

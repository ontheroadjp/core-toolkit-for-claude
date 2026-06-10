#!/bin/bash
# PreToolUse hook: block or warn on destructive shell commands (Lv0/Lv1)
set -euo pipefail

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // ""')

[ "$tool_name" != "Bash" ] && exit 0

command=$(echo "$payload" | jq -r '.tool_input.command // ""')

# ============================================================
# Lv0: Immediate abort — no bypass possible
# ============================================================

lv0_block() {
    echo "🚫 [GUARD Lv0] BLOCKED: $1"
    echo "This command has been permanently blocked and cannot be executed."
    exit 2
}

# rm -rf targeting system directories or home root
if echo "$command" | grep -qE 'rm\s[^#]*((-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+/+($|\s)|(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+~/?(\s|$)|(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+/(etc|usr|var|bin|sbin|lib|lib64|boot|home|root|dev|proc|sys)(/|\s|$))'; then
    lv0_block "rm -rf targeting system directory detected"
fi

# dd writing to block device
if echo "$command" | grep -qE '\bdd\b[^#]*\bof=/dev/'; then
    lv0_block "dd writing to block device detected"
fi

# shred targeting block device
if echo "$command" | grep -qE '\bshred\b[^#]*/dev/'; then
    lv0_block "shred targeting block device detected"
fi

# wipefs
if echo "$command" | grep -qE '(^|\s)wipefs(\s|$)'; then
    lv0_block "wipefs (filesystem signature wipe) detected"
fi

# truncate zeroing a block device
if echo "$command" | grep -qE '\btruncate\b[^#]*-s\s*0[^#]*/dev/'; then
    lv0_block "truncate -s 0 targeting block device detected"
fi

# mkfs (any variant: mkfs.ext4, mkfs.xfs, etc.)
if echo "$command" | grep -qE '(^|\s)mkfs(\.|(\s))'; then
    lv0_block "mkfs (filesystem creation/overwrite) detected"
fi

# fork bomb
if echo "$command" | grep -qF ':(){ :|:& };:'; then
    lv0_block "fork bomb detected"
fi

# chmod/chown -R on system root or system directories
if echo "$command" | grep -qE '\b(chmod|chown)\b[^#]*-[a-zA-Z]*R[a-zA-Z]*\s+/+($|\s)'; then
    lv0_block "chmod/chown -R on filesystem root detected"
fi
if echo "$command" | grep -qE '\b(chmod|chown)\b[^#]*-[a-zA-Z]*R[a-zA-Z]*\s+/(etc|usr|var|bin|sbin|lib|lib64|boot|home|root|dev|proc|sys)(/|\s|$)'; then
    lv0_block "chmod/chown -R on system directory detected"
fi

# git history rewrite
if echo "$command" | grep -qE '\bgit\b[^#]*(filter-branch|filter-repo)\b'; then
    lv0_block "git history rewrite (filter-branch/filter-repo) detected"
fi

# ============================================================
# Lv1: Block and hand off to user for manual execution
# ============================================================

lv1_warn() {
    local reason="$1"
    echo "⚠️  [GUARD Lv1] Potentially destructive command blocked: $reason"
    echo ""
    echo "INSTRUCTION FOR CLAUDE:"
    echo "  Do NOT re-run this command yourself."
    echo "  1. Show the user the command below and explain why it was blocked."
    echo "  2. Ask the user to run it manually in their terminal (e.g. with the ! prefix)."
    echo "  3. Wait for the user to report completion."
    echo "  4. Resume your work once the user confirms."
    echo ""
    echo "Command for manual execution:"
    echo "  $command"
    exit 2
}

# git force push
if echo "$command" | grep -qE '\bgit\b[^#]*\bpush\b[^#]*(--force\b|-f\b|--force-with-lease\b)'; then
    lv1_warn "git force push (may overwrite remote history)"
fi

# git reset --hard
if echo "$command" | grep -qE '\bgit\b[^#]*\breset\b[^#]*--hard\b'; then
    lv1_warn "git reset --hard (discards all uncommitted changes)"
fi

# git checkout . or git checkout -- .
if echo "$command" | grep -qE '\bgit\b[^#]*\bcheckout\b[^#]*(^|\s)\.((\s)|$)'; then
    lv1_warn "git checkout . (discards uncommitted changes)"
fi
if echo "$command" | grep -qE '\bgit\b[^#]*\bcheckout\b[^#]*--\s+\.'; then
    lv1_warn "git checkout -- . (discards uncommitted changes)"
fi

# git restore .
if echo "$command" | grep -qE '\bgit\b[^#]*\brestore\b[^#]*(^|\s)\.((\s)|$)'; then
    lv1_warn "git restore . (discards uncommitted changes)"
fi

# git clean -fd or -fdx (any combo with f and d)
if echo "$command" | grep -qE '\bgit\b[^#]*\bclean\b[^#]*-[a-zA-Z]*f[a-zA-Z]*d[a-zA-Z]*\b'; then
    lv1_warn "git clean -fd (permanently removes untracked files)"
fi

# git branch -D (force delete)
if echo "$command" | grep -qE '\bgit\b[^#]*\bbranch\b[^#]*\s-D\b'; then
    lv1_warn "git branch -D (force deletes branch, may lose commits)"
fi

# git stash drop or clear
if echo "$command" | grep -qE '\bgit\b[^#]*\bstash\b[^#]*\b(drop|clear)\b'; then
    lv1_warn "git stash drop/clear (permanently destroys stashed changes)"
fi

exit 0

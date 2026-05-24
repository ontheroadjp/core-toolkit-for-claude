#!/bin/bash
set -euo pipefail

LOG_FILE="$HOME/.claude/token-usage.log"
LINES=20
SHOW_ALL=false
SHOW_SUM=false
SHOW_MODEL=false

usage() {
  echo "Usage: $(basename "$0") [-n <count>] [-a|--all] [--sum] [--model]"
  echo "  -n <count>   Show last N entries (default: 20)"
  echo "  -a, --all    Show all entries"
  echo "  --sum        Show aggregated totals and averages"
  echo "  --model      Show per-model breakdown"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) shift; LINES="${1:?-n requires a number}"; shift ;;
    -a|--all) SHOW_ALL=true; shift ;;
    --sum) SHOW_SUM=true; shift ;;
    --model) SHOW_MODEL=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: log file not found: $LOG_FILE" >&2
  exit 1
fi

# Parse key=value fields from a log line; handles both old and new format.
PARSE_AWK='
/^\[/ {
  gsub(/=[ \t]+/, "=")
  ts = substr($0, 2, 19)
  session = model = branch = cwd = ""
  turns = tot = cr = 0; cache_ratio = 0
  for (i = 3; i <= NF; i++) {
    n = split($i, kv, "=")
    if (n < 2) continue
    if (kv[1] == "session")      session     = substr(kv[2], 1, 8)
    if (kv[1] == "model")        { model = kv[2]; sub(/^claude-/, "", model) }
    if (kv[1] == "turns")        turns       = kv[2]
    if (kv[1] == "total")        tot         = kv[2]
    if (kv[1] == "cache_read")   cr          = kv[2]
    if (kv[1] == "cache_ratio")  cache_ratio = kv[2]
    if (kv[1] == "branch")       branch      = kv[2]
    if (kv[1] == "cwd")          cwd         = kv[2]
  }
  if (model == "")  model  = "-"
  if (branch == "") branch = "-"
  if (cwd == "")    cwd    = "-"
  printf "%-19s  %-8s  %-22s  %5s  %8s  %6s%%  %-20s  %s\n", \
    ts, session, model, turns, tot, cache_ratio, branch, cwd
}'

SUM_AWK='
/^\[/ {
  gsub(/=[ \t]+/, "=")
  turns = input = output = cr = cc = tot = 0
  for (i = 3; i <= NF; i++) {
    n = split($i, kv, "=")
    if (n < 2) continue
    if (kv[1] == "input")        input  += kv[2]
    if (kv[1] == "output")       output += kv[2]
    if (kv[1] == "cache_read")   cr     += kv[2]
    if (kv[1] == "cache_create") cc     += kv[2]
    if (kv[1] == "total")        tot    += kv[2]
    if (kv[1] == "turns")        turns  += kv[2]
  }
  sessions++
  total_input += input; total_output += output
  total_cr    += cr;    total_cc     += cc
  total_tok   += tot;   total_turns  += turns
}
END {
  denom     = total_input + total_cr
  hit_rate  = (denom > 0)    ? (total_cr * 100.0 / denom)    : 0
  turns_avg = (sessions > 0) ? (total_turns  / sessions)     : 0
  tok_avg   = (sessions > 0) ? (total_tok    / sessions)     : 0
  printf "  sessions       : %d\n",     sessions
  printf "  turns  (avg)   : %.1f\n",   turns_avg
  printf "  input          : %d\n",     total_input
  printf "  output         : %d\n",     total_output
  printf "  cache_read     : %d\n",     total_cr
  printf "  cache_create   : %d\n",     total_cc
  printf "  total          : %d\n",     total_tok
  printf "  total  (avg)   : %.0f\n",   tok_avg
  printf "  cache hit rate : %.1f%%\n", hit_rate
}'

MODEL_AWK='
/^\[/ {
  gsub(/=[ \t]+/, "=")
  model = "-"
  turns = input = output = cr = cc = tot = 0
  for (i = 3; i <= NF; i++) {
    n = split($i, kv, "=")
    if (n < 2) continue
    if (kv[1] == "model")        { model = kv[2]; sub(/^claude-/, "", model) }
    if (kv[1] == "turns")        turns  = kv[2]
    if (kv[1] == "input")        input  = kv[2]
    if (kv[1] == "cache_read")   cr     = kv[2]
    if (kv[1] == "total")        tot    = kv[2]
  }
  count[model]++
  turns_sum[model] += turns
  input_sum[model] += input
  cr_sum[model]    += cr
  total_sum[model] += tot
}
END {
  printf "%-22s  %8s  %10s  %10s  %10s\n", "model", "sessions", "turns_avg", "total_avg", "cache_ratio"
  printf "%s\n", "-----------------------------------------------------------------------"
  for (m in count) {
    denom = input_sum[m] + cr_sum[m]
    ratio = (denom > 0) ? (cr_sum[m] * 100.0 / denom) : 0
    printf "%-22s  %8d  %10.1f  %10.0f  %9.1f%%\n", \
      m, count[m], turns_sum[m]/count[m], total_sum[m]/count[m], ratio
  }
}'

if "$SHOW_SUM"; then
  echo "=== Token Usage Summary ==="
  awk "$SUM_AWK" "$LOG_FILE"
  exit 0
fi

if "$SHOW_MODEL"; then
  awk "$MODEL_AWK" "$LOG_FILE"
  exit 0
fi

printf "%-19s  %-8s  %-22s  %5s  %8s  %7s  %-20s  %s\n" \
  "timestamp" "session" "model" "turns" "total" "cache%" "branch" "cwd"
printf '%s\n' "$(printf '%105s' | tr ' ' '-')"

if "$SHOW_ALL"; then
  awk "$PARSE_AWK" "$LOG_FILE"
else
  tail -n "$LINES" "$LOG_FILE" | awk "$PARSE_AWK"
fi

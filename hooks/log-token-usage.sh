#!/bin/bash
set -euo pipefail

payload=$(cat)
transcript_path=$(echo "$payload" | jq -r '.transcript_path // empty')
session_id=$(echo "$payload" | jq -r '.session_id // "unknown"')

[ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && exit 0

data=$(jq -rsc '
  [.[] | objects | select(.type == "assistant" and .message.usage != null)] as $entries |
  ($entries | length) as $turns |
  ($entries[-1].message.model // "unknown") as $model |
  ($entries[0].cwd // "") as $raw_cwd |
  ($entries[0].gitBranch // "unknown") as $branch |
  ($entries | map(.message.usage) |
  {
    input:        (map(.input_tokens                // 0) | add // 0),
    output:       (map(.output_tokens               // 0) | add // 0),
    cache_create: (map(.cache_creation_input_tokens // 0) | add // 0),
    cache_read:   (map(.cache_read_input_tokens     // 0) | add // 0)
  }) as $u |
  ($u.input + $u.cache_read) as $denom |
  {
    turns:        $turns,
    model:        $model,
    cwd:          ($raw_cwd | split("/") | map(select(length > 0)) | last // "unknown"),
    branch:       $branch,
    input:        $u.input,
    output:       $u.output,
    cache_create: $u.cache_create,
    cache_read:   $u.cache_read,
    total:        ($u.input + $u.output + $u.cache_create),
    cache_ratio:  (if $denom > 0 then (($u.cache_read * 1000 / $denom | floor) / 10) else 0 end)
  }
' "$transcript_path") || exit 0

turns=$(echo "$data"        | jq -r '.turns')
model=$(echo "$data"        | jq -r '.model')
cwd=$(echo "$data"          | jq -r '.cwd')
branch=$(echo "$data"       | jq -r '.branch')
input=$(echo "$data"        | jq -r '.input')
output=$(echo "$data"       | jq -r '.output')
cache_create=$(echo "$data" | jq -r '.cache_create')
cache_read=$(echo "$data"   | jq -r '.cache_read')
total=$(echo "$data"        | jq -r '.total')
cache_ratio=$(echo "$data"  | jq -r '.cache_ratio')

log_file="$HOME/.claude/token-usage.log"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

printf '[%s] session=%-36s  model=%-30s  turns=%3d  input=%6d  output=%6d  cache_read=%7d  cache_create=%6d  total=%7d  cache_ratio=%5.1f  branch=%-20s  cwd=%s\n' \
  "$timestamp" "$session_id" "$model" "$turns" \
  "$input" "$output" "$cache_read" "$cache_create" "$total" \
  "$cache_ratio" "$branch" "$cwd" \
  >> "$log_file"

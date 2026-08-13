#!/usr/bin/env bash
# Claude Code status line: model, context %, tokens, cost estimate, session duration

# Force US number formatting (period decimal separator) regardless of system locale.
export LC_NUMERIC=C

input=$(cat)

# --- Model ---
model_name=$(printf '%s' "$input" | jq -r '.model.display_name // "Unknown"')

# --- Context window ---
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
total_in=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')

# --- Session duration via transcript birth time (APFS) ---
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
duration_str=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  birth=$(stat -f %B "$transcript" 2>/dev/null)
  if [ -n "$birth" ] && [ "$birth" -gt 0 ] 2>/dev/null; then
    now=$(date +%s)
    elapsed=$(( now - birth ))
    h=$(( elapsed / 3600 ))
    m=$(( (elapsed % 3600) / 60 ))
    if [ "$h" -gt 0 ]; then
      duration_str="${h}h ${m}m"
    else
      duration_str="${m}m"
    fi
  fi
fi

# --- Cost estimate (per-MTok prices, May 2025) ---
# Prices: input $3/MTok, output $15/MTok for claude-sonnet-4 class
# Adjust model_id prefix matching for other models as needed
model_id=$(printf '%s' "$input" | jq -r '.model.id // ""')
in_price=3.0
out_price=15.0
case "$model_id" in
  claude-opus-4*|claude-opus-4-5*)      in_price=15.0;  out_price=75.0  ;;
  claude-sonnet-4*|claude-sonnet-4-5*)  in_price=3.0;   out_price=15.0  ;;
  claude-haiku-3-5*)                    in_price=0.8;   out_price=4.0   ;;
  claude-haiku-3*)                      in_price=0.25;  out_price=1.25  ;;
  claude-opus-3-5*|claude-opus-3*)      in_price=15.0;  out_price=75.0  ;;
  claude-sonnet-3-5*|claude-sonnet-3*)  in_price=3.0;   out_price=15.0  ;;
esac
cost=$(awk -v ti="$total_in" -v to="$total_out" -v ip="$in_price" -v op="$out_price" \
  'BEGIN { c = (ti * ip + to * op) / 1000000; printf "%.4f", c }')

# --- Assemble output ---
parts=()
parts+=("$model_name")

if [ -n "$used_pct" ]; then
  ctx=$(printf '%.0f' "$used_pct")
  parts+=("ctx:${ctx}%")
fi

# tokens: show in K if >= 1000
fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000 ] 2>/dev/null; then
    awk -v n="$n" 'BEGIN { printf "%.1fK", n/1000 }'
  else
    printf '%s' "$n"
  fi
}
in_fmt=$(fmt_tokens "$total_in")
out_fmt=$(fmt_tokens "$total_out")
parts+=("${in_fmt}in/${out_fmt}out")

parts+=("\$${cost}")

[ -n "$duration_str" ] && parts+=("$duration_str")

# Join with " | "
result=""
for p in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$p"
  else
    result="$result | $p"
  fi
done

printf '%s' "$result"

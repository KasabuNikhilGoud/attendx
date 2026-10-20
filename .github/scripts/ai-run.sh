#!/usr/bin/env bash
# ai-run.sh — run an OpenCode agent on the best available FREE model (keyless).
#
# Usage: bash .github/scripts/ai-run.sh <agent> <prompt> <output-file>
#
# Why: OpenCode Zen free models change/rotate and rate-limit independently.
# Instead of hardcoding one model, we discover the currently available free
# models with `opencode models`, order them by preference, and try them one
# by one until one succeeds. Set the OPENCODE_MODEL env var to bypass
# discovery and force one exact model.

set -u

AGENT="$1"
PROMPT="$2"
OUT="$3"
DIR="$(dirname "$OUT")"
LOG="$DIR/run.log"
mkdir -p "$DIR"

# Preferred order (used first when currently available).
PREFER=(
  opencode/glm-5.3-flash-free
  opencode/deepseek-v4.1-flash-free
  opencode/nemotron-3.5-super-vl-free
  opencode/nemotron-3.5-lightning-free
  opencode/minimax-m3.1-flash-free
  opencode/longcat-2.5-preview-free
  opencode/mimo-v2.6-flash-free
  opencode/beam-free
)

candidates=()

if [ -n "${OPENCODE_MODEL:-}" ]; then
  # Explicit override always wins.
  candidates+=("$OPENCODE_MODEL")
else
  # 1. Discover currently listed free models (keyless, public catalog).
  #    `awk '{print $1}'` normalizes rows to the bare model id in case the
  #    listing ever grows extra columns/padding.
  avail="$(opencode models 2>/dev/null | awk '{print $1}' | grep -E '^opencode/.*free' || true)"

  # 2. Preferred models that are available right now.
  for m in "${PREFER[@]}"; do
    grep -qx "$m" <<<"$avail" && candidates+=("$m")
  done

  # 3. Any other free model not already included (new ones get a chance).
  while IFS= read -r m; do
    [ -n "$m" ] || continue
    dup=0
    for c in ${candidates[@]+"${candidates[@]}"}; do
      [ "$c" = "$m" ] && dup=1 && break
    done
    [ "$dup" -eq 0 ] && candidates+=("$m")
  done <<<"$avail"

  # 4. Safety net: preferred models that were NOT listed still get tried
  #    last — covers malformed listings and rotation back into service.
  for m in "${PREFER[@]}"; do
    dup=0
    for c in ${candidates[@]+"${candidates[@]}"}; do
      [ "$c" = "$m" ] && dup=1 && break
    done
    [ "$dup" -eq 0 ] && candidates+=("$m")
  done

  # 5. Hard cap on attempts so worst-case retries fit inside the job
  #    timeout (5 models x 4 min = 20 min; jobs allow 25 min).
  if [ ${#candidates[@]} -gt 5 ]; then
    candidates=("${candidates[@]:0:5}")
  fi
fi

echo "[ai-run] candidates: ${candidates[*]}" >&2

for m in "${candidates[@]}"; do
  echo "[ai-run] trying model: $m" >&2
  # 4-minute cap per model so one hung model doesn't eat the whole job.
  if timeout 240 opencode run --standalone --auto \
      --model "$m" --agent "$AGENT" "$PROMPT" >"$OUT" 2>"$LOG" \
      && [ -s "$OUT" ]; then
    echo "[ai-run] success with $m" >&2
    printf '%s' "$m" > "$DIR/model-used.txt"
    exit 0
  fi
  # Never leave partial output behind — the post step treats its absence
  # as "all models failed".
  rm -f "$OUT"
  echo "[ai-run] model $m failed:" >&2
  tail -n 5 "$LOG" 2>/dev/null >&2 || true
done

echo "[ai-run] ALL free models failed" >&2
exit 1

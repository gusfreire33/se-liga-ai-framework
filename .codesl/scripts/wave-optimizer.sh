#!/bin/bash

# =============================================================================
# Wave Optimizer (Parallel Dispatch)
# Topological sort (Kahn's algorithm) for task DAGs → parallel execution waves.
# Used by /sl.dispatch (skill: sl-parallel-dispatch) and as the objective
# `check` for veto V1.4 (circular dependency) — see skill sl-veto-conditions.
#
# CODE > LLM: deterministic ordering + cycle detection in pure bash. No LLM.
# =============================================================================
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  wave-optimizer.sh [--check-cycles] [FILE]

Input (FILE or stdin): one task per line, TAB-separated:
    <task_id><TAB><comma-separated dependency ids | empty>
  Lines starting with # and blank lines are ignored.

Output:
  Wave 1: <ids running in parallel>
  Wave 2: ...
Exit codes:
  0  acyclic — waves printed (or, with --check-cycles, "OK: acyclic")
  1  cycle detected (unprocessed nodes listed)  → veto V1.4 hard_block
  2  usage / input error

Example:
  printf 'A\t\nB\t\nC\tA\nD\tA,B\nE\tC,D\n' | wave-optimizer.sh
EOF
}

CHECK_ONLY=0
FILE=""
for arg in "$@"; do
  case "$arg" in
    --check-cycles) CHECK_ONLY=1 ;;
    -h|--help) usage; exit 2 ;;
    *) FILE="$arg" ;;
  esac
done

INPUT="$( [ -n "$FILE" ] && cat -- "$FILE" || cat )"

# Parse into parallel arrays: ids[], deps[] (deps as space-separated)
nodes=()
declare -A DEPS=()
declare -A KNOWN=()

while IFS=$'\t' read -r id rest || [ -n "${id:-}" ]; do
  # strip comments / blanks / CR (Windows line endings)
  id="${id%$'\r'}"; rest="${rest%$'\r'}"
  case "$id" in ''|\#*) continue ;; esac
  nodes+=("$id"); KNOWN["$id"]=1
  DEPS["$id"]="${rest//,/ }"
done <<< "$INPUT"

[ "${#nodes[@]}" -gt 0 ] || { echo "ERRO: nenhuma task no input." >&2; exit 2; }

# Validate referenced deps exist
for id in "${nodes[@]}"; do
  for d in ${DEPS["$id"]:-}; do
    [ -n "${KNOWN[$d]:-}" ] || { echo "ERRO: '$id' depende de '$d' que não existe." >&2; exit 2; }
  done
done

# Kahn's algorithm in waves: each wave = all nodes whose deps are all done.
declare -A DONE=()
remaining="${#nodes[@]}"
wave=0

while [ "$remaining" -gt 0 ]; do
  ready=()
  for id in "${nodes[@]}"; do
    [ -n "${DONE[$id]:-}" ] && continue
    ok=1
    for d in ${DEPS["$id"]:-}; do
      [ -n "${DONE[$d]:-}" ] || { ok=0; break; }
    done
    [ "$ok" -eq 1 ] && ready+=("$id")
  done

  # No node became ready but work remains → cycle.
  if [ "${#ready[@]}" -eq 0 ]; then
    pending=()
    for id in "${nodes[@]}"; do [ -z "${DONE[$id]:-}" ] && pending+=("$id"); done
    echo "❌ V1.4: dependência circular — nós não resolvíveis: ${pending[*]}" >&2
    exit 1
  fi

  wave=$((wave+1))
  [ "$CHECK_ONLY" -eq 0 ] && echo "Wave $wave: ${ready[*]}"
  for id in "${ready[@]}"; do DONE["$id"]=1; remaining=$((remaining-1)); done
done

[ "$CHECK_ONLY" -eq 1 ] && echo "OK: acyclic ($wave waves)"
exit 0

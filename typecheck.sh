#!/usr/bin/env bash
# Type-check all generated Dhall files.
#
# Usage:
#   ./typecheck.sh [dir]      # default dir: devops-dhall
#   ./typecheck.sh -v [dir]   # -v: print every file's result, not just failures
#
# Requires: dhall (https://github.com/dhall-lang/dhall-haskell)
# Exit code is non-zero if any file fails to type-check.

set -uo pipefail

VERBOSE=0
if [[ "${1:-}" == "-v" ]]; then
  VERBOSE=1
  shift
fi

DIR="${1:-devops-dhall}"

if ! command -v dhall >/dev/null 2>&1; then
  echo "error: 'dhall' not found on PATH" >&2
  exit 127
fi

if [[ ! -d "$DIR" ]]; then
  echo "error: directory '$DIR' does not exist" >&2
  exit 1
fi

# Parallelism: one worker per core, leaving headroom.
JOBS="$(( $(nproc 2>/dev/null || echo 4) ))"

# Per-file checker invoked by xargs. Prints "FAIL <path>" on failure,
# and (when verbose) "OK <path>" on success.
check_one() {
  local f="$1"
  if dhall type --file "$f" >/dev/null 2>&1; then
    [[ "$VERBOSE" == "1" ]] && echo "OK   $f"
    return 0
  else
    echo "FAIL $f"
    return 1
  fi
}
export -f check_one
export VERBOSE

RESULTS="$(mktemp)"
trap 'rm -f "$RESULTS"' EXIT

find "$DIR" -name '*.dhall' -print0 \
  | sort -z \
  | xargs -0 -P "$JOBS" -I {} bash -c 'check_one "$@"' _ {} \
  > "$RESULTS"

# Failures were printed with a FAIL prefix; show them in order.
FAILS="$(grep -c '^FAIL ' "$RESULTS" || true)"
TOTAL="$(find "$DIR" -name '*.dhall' | wc -l | tr -d ' ')"
OK="$(( TOTAL - FAILS ))"

if [[ "$VERBOSE" == "1" ]]; then
  sort "$RESULTS"
elif [[ "$FAILS" -gt 0 ]]; then
  grep '^FAIL ' "$RESULTS" | sort
fi

echo
echo "Type-check: $OK/$TOTAL passed, $FAILS failed  (dir: $DIR)"

[[ "$FAILS" -eq 0 ]]

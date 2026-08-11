#!/usr/bin/env bash
# Run the shared routing benchmark through the Bash structured router.
# Usage:
#   bash skills/scripts/test-routing.sh
#   bash skills/scripts/test-routing.sh --quick
#   bash skills/scripts/test-routing.sh --benchmark path/to/routing-benchmark.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BENCHMARK="$SKILLS_ROOT/tests/routing-benchmark.json"
QUICK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick|-Quick|-quick)
      QUICK=1
      shift
      ;;
    --benchmark|-Benchmark|-benchmark)
      if [[ $# -lt 2 ]]; then
        echo 'ERROR: --benchmark requires a path' >&2
        exit 2
      fi
      BENCHMARK="$2"
      shift 2
      ;;
    -h|--help)
      echo 'Usage: test-routing.sh [--quick] [--benchmark PATH]'
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

PYTHON=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    PYTHON="$candidate"
    break
  fi
done
if [[ -z "$PYTHON" ]]; then
  echo 'ERROR: Python 3 is required by the Bash routing benchmark runner.' >&2
  exit 2
fi
if [[ ! -f "$BENCHMARK" ]]; then
  echo "ERROR: benchmark not found: $BENCHMARK" >&2
  exit 2
fi

"$PYTHON" - "$BENCHMARK" "$SCRIPT_DIR/master-route.sh" "$QUICK" <<'PY'
import json
import pathlib
import re
import subprocess
import sys
import tempfile

benchmark_path = pathlib.Path(sys.argv[1])
router_path = pathlib.Path(sys.argv[2])
quick = sys.argv[3] == "1"

try:
    benchmark = json.loads(benchmark_path.read_text(encoding="utf-8-sig"))
except (OSError, json.JSONDecodeError) as exc:
    print(f"ERROR: benchmark is not valid JSON: {exc}", file=sys.stderr)
    raise SystemExit(2)

cases = benchmark.get("cases")
if not isinstance(cases, list):
    print("ERROR: benchmark.cases must be an array", file=sys.stderr)
    raise SystemExit(2)
if quick:
    cases = [case for case in cases if isinstance(case, dict) and case.get("quick")]

failures = []
passed = 0
print(f"=== test-routing.sh | {len(cases)} cases (quick={quick}) ===")

with tempfile.TemporaryDirectory(prefix="rs-routing-bash-") as scratch:
    scratch_path = pathlib.Path(scratch)
    for index, case in enumerate(cases):
        if not isinstance(case, dict) or not isinstance(case.get("hint"), str) or not isinstance(case.get("expect"), str):
            failures.append(f"case[{index}] has invalid hint/expect fields")
            continue

        hint = case["hint"]
        expected = case["expect"]
        out_dir = scratch_path / str(index)
        result = subprocess.run(
            ["bash", str(router_path), "--hint", hint, "--out-dir", str(out_dir)],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )

        got = "ERR"
        scope_path = out_dir / "route-scope.md"
        if result.returncode == 0 and scope_path.is_file():
            text = scope_path.read_text(encoding="utf-8")
            match = re.search(r"(?m)^- primary:[ \t]*(\S+)[ \t]*$", text)
            if match:
                got = match.group(1)

        if got == expected:
            passed += 1
            continue

        detail = result.stderr.strip().splitlines()
        stderr_tail = detail[-1] if detail else ""
        message = f"hint={hint!r} expect={expected} got={got} exit={result.returncode}"
        if stderr_tail:
            message += f" stderr={stderr_tail!r}"
        failures.append(message)

print("=== ROUTING TEST SUMMARY ===")
print(f"TOTAL={len(cases)}")
print(f"PASS={passed}")
print(f"FAIL={len(failures)}")
print(f"QUICK={quick}")

if failures:
    for failure in failures:
        print(f"[FAIL] {failure}", file=sys.stderr)
    print(f"OVERALL: FAIL ({len(failures)})", file=sys.stderr)
    raise SystemExit(1)

print(f"OVERALL: ALL PASS ({passed})")
PY

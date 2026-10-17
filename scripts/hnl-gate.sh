#!/usr/bin/env bash
# hnl gate — `typecheck` + `lint` + `test` over this repo's `.hnl` packages.
#
# The `.hnl` corpus is not covered by `cargo test`; this is its gate.
# `.handl.toml` wires cross-repo imports by *name* (ADR-0128 Phase 5), so the
# sibling checkouts it names must be present. CI clones them; locally they
# already are. A missing sibling is a hard error: without it a name import
# degrades to a decorative declaration and the tools would pass on nothing.
#
# Usage:
#   HNL=../cli/target/debug/hnl scripts/hnl-gate.sh
#   (cd ../cli && cargo build --bin hnl && cd -)   # if the binary is missing
set -euo pipefail

HNL="${HNL:-../cli/target/debug/hnl}"
if [ ! -x "$HNL" ]; then
  echo "error: no hnl binary at '$HNL'" >&2
  echo "       build it:   (cd ../cli && cargo build --bin hnl)" >&2
  exit 1
fi

# Every sibling path named by the manifest must exist.
missing=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  case "$p" in
    ../*)
      if [ ! -e "$p" ]; then
        echo "error: .handl.toml names '$p', which is not present" >&2
        echo "       clone the sibling repo next to this one" >&2
        missing=1
      fi
      ;;
  esac
done < <(sed -n 's/.*path *= *"\([^"]*\)".*/\1/p' .handl.toml 2>/dev/null)
[ "$missing" -eq 0 ] || exit 1

mapfile -t sources < <(find handl-packages -name '*.hnl' ! -name '*.test.hnl' | sort)
mapfile -t tests < <(find handl-packages -name '*.test.hnl' | sort)
if [ "${#sources[@]}" -eq 0 ]; then
  echo "error: no .hnl sources under handl-packages/" >&2
  exit 1
fi

echo "== hnl typecheck (${#sources[@]} sources, ${#tests[@]} test files) =="
"$HNL" typecheck "${sources[@]}" ${tests[@]+"${tests[@]}"}

echo
echo "== hnl lint =="
"$HNL" lint "${sources[@]}" ${tests[@]+"${tests[@]}"}

if [ "${#tests[@]}" -gt 0 ]; then
  echo
  # `--jobs 1` inside each file: several suites share one fixture server
  # (fetch-c's canned server even shuts down on GET /done), so running a
  # file's cases concurrently makes them fight over it. Files are still
  # independent of each other.
  echo "== hnl test (per file; in-file jobs: 1) =="
  for t in "${tests[@]}"; do
    echo "-- $t"
    "$HNL" test --jobs 1 "$t"
  done
fi

echo
echo "hnl gate passed."

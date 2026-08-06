#!/usr/bin/env bash
# Copy the canonical style and macro files into templates/ so each template
# directory is self-contained.
#
# WHY THE DUPLICATION: Overleaf users cannot install packages, and Overleaf
# has no notion of a parent directory outside the uploaded project. So the
# directory a student uploads must carry its own .sty and macro files. The
# canonical copies live in tex/ and macros/; this script mirrors them, and
# `--check` fails if the two have drifted, which CI runs on every push.
#
#   tools/sync-templates.sh          copy into templates/
#   tools/sync-templates.sh --check  exit 1 if a template is stale
set -euo pipefail

cd "$(dirname "$0")/.."

FILES=(
  tex/almacore.sty:templates/notes/almacore.sty
  tex/svnotes.sty:templates/notes/svnotes.sty
  macros/alma-micro.tex:templates/notes/macros/alma-micro.tex
  macros/alma-metrics.tex:templates/notes/macros/alma-metrics.tex
  macros/alma-macro.tex:templates/notes/macros/alma-macro.tex
  tex/almacore.sty:templates/beamer/almacore.sty
  tex/beamerthemeSaintVincent.sty:templates/beamer/beamerthemeSaintVincent.sty
)

if [[ "${1:-}" == "--check" ]]; then
  status=0
  for pair in "${FILES[@]}"; do
    src="${pair%%:*}"; dest="${pair##*:}"
    if [[ ! -f "$dest" ]]; then
      echo "MISSING: $dest"; status=1
    elif ! diff -q "$src" "$dest" >/dev/null; then
      echo "DRIFTED: $dest differs from $src"; status=1
    fi
  done
  [[ $status -eq 0 ]] && echo "templates/ is in sync with tex/ and macros/"
  exit $status
fi

mkdir -p templates/notes/macros templates/beamer
for pair in "${FILES[@]}"; do
  src="${pair%%:*}"; dest="${pair##*:}"
  cp "$src" "$dest"
  echo "synced $dest"
done

# almacore.sty is authored in the problem-set repository. If a sibling clone
# is present, warn when the two copies have diverged.
SIBLING=../Latex_Template_Economics_ProblemSet/tex/almacore.sty
if [[ -f "$SIBLING" ]] && ! diff -q "$SIBLING" tex/almacore.sty >/dev/null; then
  echo
  echo "WARNING: tex/almacore.sty differs from the copy in the sibling"
  echo "         problem-set repository. Reconcile before releasing."
fi

#!/bin/zsh
set -euo pipefail

project_dir="${PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$project_dir"

blocked="$(git ls-files | rg '(^|/)(AGENT_STATE\.md|BUILD_STATUS\.json|NEXT_BOT_GOAL_LOOP_PROMPT\.md|.*Agent_Goal_Loop\.md|.*iPadOS_PRD\.md|.*\.(ipa|mobileprovision|p12|cer|key|xcarchive|xcresult))$' || true)"
if [[ -n "$blocked" ]]; then
  print -u2 "Public repository blocked: internal or signing files are tracked:"
  print -u2 -r -- "$blocked"
  exit 1
fi

for protected_dir in Resources/FidelityDev Resources/JSKidPix; do
  case "$protected_dir" in
    Resources/FidelityDev) allowed="$protected_dir/README.md" ;;
    Resources/JSKidPix) allowed="$protected_dir/.gitkeep" ;;
  esac
  unexpected="$(git ls-files "$protected_dir" | rg -v "^${allowed}$" || true)"
  if [[ -n "$unexpected" ]]; then
    print -u2 "Public repository blocked: private reference files are tracked:"
    print -u2 -r -- "$unexpected"
    exit 1
  fi
done

ignored_tracked="$(git ls-files -ci --exclude-standard || true)"
if [[ -n "$ignored_tracked" ]]; then
  print -u2 "Public repository blocked: files ignored by policy are still tracked:"
  print -u2 -r -- "$ignored_tracked"
  exit 1
fi

if git grep -I -n -E '/Users/|/home/|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|gh[pousr]_[A-Za-z0-9_]+|AKIA[0-9A-Z]{16}' -- . ':!Scripts/verify_public_repo.sh'; then
  print -u2 "Public repository blocked: a local path, private key, or credential-like value was found."
  exit 1
fi

print "Public repository policy passed."

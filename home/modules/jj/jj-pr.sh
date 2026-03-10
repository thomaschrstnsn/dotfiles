#! /bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: jj-pr <revision>"
  exit 1
fi

REV=$1
echo creating PR from revision
jj log -r "$REV" -G
echo

BRANCH=$(jj log -T "self.local_bookmarks()" --no-graph --color=never -r "$REV")
if [ -z "$BRANCH" ]; then
  gum log -l error Revision is without local bookmark, cannot create PR
  exit 1
fi
echo local bookmark/branch "$BRANCH"

SYNCED=$(jj log -T 'self.local_bookmarks().any(|bm| bm.synced()) && self.remote_bookmarks().any(|bm| bm.synced())' --no-graph --color=never -r "$REV")

if [ "$SYNCED" = "true" ]; then
  echo ✅ bookmark is synced with remote
else
  echo ❌ bookmark is NOT synced with remote
  gum confirm "bookmark does not appear to be synced/pushed, continue anyways?" --negative="Stop" --affirmative="Ignore issue" --default=false || exit 1
fi

# trunk() may have multiple bookmarks; prefer main/master, otherwise take the first
TRUNK=$(jj log -T 'self.local_bookmarks().map(|b| b.name() ++ "\n")' --no-graph --color=never -r 'trunk()' \
  | grep -m1 -E '^(main|master)$' \
  || jj log -T 'self.local_bookmarks().map(|b| b.name() ++ "\n")' --no-graph --color=never -r 'trunk()' \
  | grep -m1 .)

echo trunk "$TRUNK"

TITLE=$(gum input --placeholder="title")
echo title "$TITLE"

gum confirm "create the pr?" || exit 1

BODY_ARGS=()
if command -v jj-ai-pr-describe &>/dev/null && gum confirm "generate AI description?" --default=true; then
  echo "Generating PR description..."
  BODY_FILE=$(mktemp /tmp/jj-pr-body-XXXXXX.md)
  trap 'rm -f "$BODY_FILE"' EXIT
  jj-ai-pr-describe "$REV" > "$BODY_FILE"
  BODY_ARGS=(--body-file "$BODY_FILE")
fi

gh pr create -B "$TRUNK" -H "$BRANCH" --title "$TITLE" "${BODY_ARGS[@]}" -w

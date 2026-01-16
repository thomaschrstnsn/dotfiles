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

BRANCH=$(jj log -T "self.local_bookmarks()" -G -r "$REV")
if [ -z "$BRANCH" ]; then
  gum log -l error Revision is without local bookmark, cannot create PR
  exit 1
fi
echo local bookmark/branch "$BRANCH"

SYNCED=$(jj log -T 'self.local_bookmarks().any(|bm| bm.synced()) && self.remote_bookmarks().any(|bm| bm.synced())' -G -r "$REV")

if [ "$SYNCED" = "true" ]; then
  echo ✅ bookmark is synced with remote
else
  echo ❌ bookmark is NOT synced with remote
  gum confirm "bookmark does not appear to be synced/pushed, continue anyways?" --negative="Stop" --affirmative="Ignore issue" --default=false || exit 1
fi

TRUNK=$(jj log -T 'self.local_bookmarks()' -G -r 'trunk()')

echo trunk "$TRUNK"

TITLE=$(gum input --placeholder="title")
echo title "$TITLE"

gum confirm "create the pr?" || exit 1

# jj-pr-diff "$REV" | fabric -p write_pull-request | gh pr create -B "$TRUNK" --body-file - -H "$BRANCH" --title "$TITLE" -w
gh pr create -B "$TRUNK" -H "$BRANCH" --title "$TITLE" -w

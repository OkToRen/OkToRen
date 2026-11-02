#!/usr/bin/env bash
# Rewrites the "Recently pushed" list in README.md. The users/<name>/repos
# endpoint only returns public repos, so private work never appears here.
set -euo pipefail

owner="${1:?usage: update-recent.sh <github-user>}"

list=$(gh api "users/$owner/repos?type=owner&sort=pushed&per_page=20" --jq "
  [.[] | select(.fork == false and .name != \"$owner\")][:5][]
  | \"- [\(.name)](\(.html_url))\(if .language then \" (\(.language))\" else \"\" end), \(.pushed_at[:10])\"")

# Keep the existing list if the API returned nothing.
[ -n "$list" ] || exit 0

sed -i '/<!-- recent:start -->/,/<!-- recent:end -->/{//!d}' README.md
printf '%s\n' "$list" | sed -i '/<!-- recent:start -->/r /dev/stdin' README.md

#!/usr/bin/env bash
set -e

command -v gh >/dev/null || {
  echo "GitHub CLI (gh) is required"
  exit 1
}

gh auth status >/dev/null || {
  echo "You must be authenticated with gh"
  exit 1
}

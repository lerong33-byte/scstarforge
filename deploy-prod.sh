#!/bin/bash
# deploy-prod.sh — Deploy to live (prod remote) with -DEV stripped from version
# Usage: bash deploy-prod.sh
# Only run this when explicitly approved by the user.

set -e

BRANCH=main
SRC=index.html
TMP=/tmp/scstarforge-prod-deploy.html

echo "==> Building prod version (stripping -DEV)..."
sed 's/-DEV//g' "$SRC" > "$TMP"

echo "==> Stashing current dev state..."
git stash

echo "==> Applying prod version..."
cp "$TMP" "$SRC"

echo "==> Committing prod version..."
CURRENT_VER=$(grep -o 'v[0-9]*\.[0-9]*' "$SRC" | head -1)
git add "$SRC"
git commit -m "PROD: $CURRENT_VER — deployed to live (no -DEV)"

echo "==> Pushing to prod remote..."
git push prod "$BRANCH"

echo "==> Restoring dev state..."
git checkout HEAD~1 -- "$SRC"
git stash pop 2>/dev/null || true

echo "==> Done. Live site updated to $CURRENT_VER"

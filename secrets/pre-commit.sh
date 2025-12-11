#!/bin/bash
# secrets/pre-commit.sh
# Prevent committing unencrypted secrets in secrets/ directory

failed=0

# Loop over staged files in secrets/
for file in $(git diff --cached --name-only | grep '^secrets/' | sort -u || true); do
  if [[ ! -f "$file" ]]; then
    continue
  fi
  if [[ "$file" =~ \.ya?ml$ ]]; then
    if ! grep -q 'sops:' "$file"; then
      echo "Unencrypted secret detected in $file"
      failed=1
    fi
  fi
done

if [ $failed -eq 1 ]; then
  echo "Commit aborted. Please encrypt secrets with SOPS before committing."
  exit 1
fi

#!/bin/bash
set -e

# Prerequisites:
# - Repo cloned from GitHub with existing README.md and main branch
# - gh CLI installed and authenticated

echo "Using existing GitHub repository."

# Step 1: ensure .git exists
if [ ! -d ".git" ]; then
  git init
fi

# Step 2: handle master -> main rename, and ensure develop exists
branches=$(git branch --list)

if echo "$branches" | grep -q "master"; then
  git branch -m master main
fi

branches=$(git branch --list)

if ! echo "$branches" | grep -q "develop"; then
  git checkout -b develop main
fi

# Step 3: push develop to remote
git push -u origin develop

# Step 4: branch protection for main and develop
for branch in main develop; do
    echo '{
    "required_status_checks": null,
    "enforce_admins": true,
    "required_pull_request_reviews": {
        "required_approving_review_count": 0
    },
    "restrictions": null
    }' | gh api repos/:owner/:repo/branches/$branch/protection --method PUT --input -
done

echo "Setup complete: main + develop exist, develop pushed, branch protection applied."
echo "Create your first feature branch from develop:"
echo "  git checkout -b feature/{TICKET}--{PR_NAME} develop"
echo " git commit -m "{TICKET} -- message"

echo "After committing, push and open a PR into develop:"
echo "  git push -u origin feature/{TICKET}--PR_NAME}"
echo "  gh pr create --base develop --title 'title' --body 'body'"

echo "After merging PR on GitHub"
echo "  git checkout develop"
echo "  git pull"

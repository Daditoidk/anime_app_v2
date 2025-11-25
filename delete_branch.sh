#!/bin/bash

# --- Safety Checks ---

# 1. Check if a branch name was provided
if [ -z "$1" ]; then
  echo "❌ Error: You must provide a branch name as an argument."
  echo "Usage: ./delete_branch.sh <branch-to-delete>"
  exit 1
fi

BRANCH_TO_DELETE=$1
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 2. Check if the branch exists locally
if ! git rev-parse --verify --quiet "$BRANCH_TO_DELETE"; then
  echo "⚠️ Warning: Local branch '$BRANCH_TO_DELETE' does not exist."
fi

# 3. Check if the branch is the current branch
if [ "$BRANCH_TO_DELETE" == "$CURRENT_BRANCH" ]; then
  echo "❌ Error: Cannot delete the current branch ($CURRENT_BRANCH)."
  echo "Please switch to 'main' or another branch first (e.g., git switch main)."
  exit 1
fi

# --- Deletion Commands ---

echo "--- Deleting Branch: $BRANCH_TO_DELETE ---"

# Delete the remote branch
echo "1. Attempting to delete remote branch 'origin/$BRANCH_TO_DELETE'..."
if git push origin --delete "$BRANCH_TO_DELETE"; then
  echo "✅ Remote branch deleted successfully."
else
  echo "⚠️ Warning: Could not delete remote branch (it may not exist remotely)."
fi

# Delete the local branch (using -d for safe deletion)
echo "2. Attempting to delete local branch '$BRANCH_TO_DELETE'..."
if git branch -d "$BRANCH_TO_DELETE"; then
  echo "✅ Local branch deleted successfully."
else
  # If -d fails (unmerged changes), offer -D option
  echo "❌ Safe deletion failed (unmerged changes found)."
  read -r -p "Do you want to FORCE delete the local branch? (y/N): " response
  
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    git branch -D "$BRANCH_TO_DELETE"
    echo "✅ Local branch forcibly deleted."
  else
    echo "🚫 Local branch retention requested. No action taken."
  fi
fi

echo "--- Operation Complete ---"
#!/bin/bash
# e is for exiting the script automatically if a command fails, u is for exiting if a variable is not set
# x would be for showing the commands before they are executed
set -eu
shopt -s globstar

# FUNCTIONS
# Function for setting up git env in the docker container (copied from https://github.com/stefanzweifel/git-auto-commit-action/blob/master/entrypoint.sh)
_git_setup ( ) {
    cat <<- EOF > $HOME/.netrc
      machine github.com
      login $GITHUB_ACTOR
      password $INPUT_GITHUB_TOKEN
      machine api.github.com
      login $GITHUB_ACTOR
      password $INPUT_GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Action"
}

# Checks if any files are changed
_git_changed() {
    [[ -n "$(git status -s)" ]]
}

_git_changes() {
    git diff
}

(
# PROGRAM
# Changing to the directory
cd "$GITHUB_ACTION_PATH"

FORMATTER_RESULT=0
echo "Formatting files..."
echo "Files:"
gofumpt $INPUT_FORMATTER_OPTIONS \
  || { FORMATTER_RESULT=$?; echo "Problem running gofumpt with $INPUT_FORMATTER_OPTIONS"; exit 1; }

# To keep runtime good, just continue if something was changed
if _git_changed; then
  # case when --write is used with dry-run so if something is unpretty there will always have _git_changed
  if $INPUT_DRY; then
    echo "Unformat Files Changes:"
    _git_changes
    echo "Finishing dry-run. Exiting before committing."
    exit 1
  else
    # Calling method to configure the git environemnt
    _git_setup

    if $INPUT_ONLY_CHANGED; then
      # --diff-filter=d excludes deleted files
      for file in $(git diff --name-only --diff-filter=d HEAD^..HEAD)
      do
        git add $file
      done
    else
      # Add changes to git
      git add "${INPUT_FILE_PATTERN}" || echo "Problem adding your files with pattern ${INPUT_FILE_PATTERN}"
    fi

    # Commit and push changes back
    if $INPUT_SAME_COMMIT; then
      echo "Amending the current commit..."
      git pull
      git commit --amend --no-edit
      git push origin -f
    else
      git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>" ${INPUT_COMMIT_OPTIONS:+"$INPUT_COMMIT_OPTIONS"} || echo "No files added to commit"
      git push origin ${INPUT_PUSH_OPTIONS:-}
    fi
    echo "Changes pushed successfully."
  fi
else
  # case when --check is used so there will never have something to commit but there are formattded files
  if [ "$FORMATTER_RESULT" -eq 1 ]; then
    echo "Formatter found unformatted files!"
    exit 1
  else
    echo "Finishing dry-run."
  fi
  echo "No unformatted files!"
  echo "Nothing to commit. Exiting."
fi
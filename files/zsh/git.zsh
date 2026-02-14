GIT_FETCH_THROTTLE_SECONDS=${GIT_FETCH_THROTTLE_SECONDS:-300}

_git_sync() {
  [[ ! -d .git ]] && return
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local default=$(_default_branch)

  if [[ "$current_branch" = "$default" ]]; then
    echo "🕵️ Checking for new commits 🔎"
    git pull --tags origin "$default"
    return
  fi

  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  [[ -z "$repo_root" ]] && return
  local cache_dir="${TMPDIR:-/tmp}/git-fetch-throttle"
  local cache_file="$cache_dir/$(echo "$repo_root" | shasum -a 256 | cut -d' ' -f1)"
  local now=$(date +%s)
  local should_fetch=true

  mkdir -p "$cache_dir" 2>/dev/null

  if [[ -f "$cache_file" ]]; then
    local last_fetch=$(cat "$cache_file" 2>/dev/null)
    [[ $((now - last_fetch)) -lt $GIT_FETCH_THROTTLE_SECONDS ]] && should_fetch=false
  fi

  local fetch_failed=false
  if [[ "$should_fetch" = true ]]; then
    git fetch origin "$default" -q 2>/dev/null && echo "$now" > "$cache_file" || fetch_failed=true
  fi

  local behind=$(git rev-list --count HEAD..origin/"$default" 2>/dev/null)
  if [[ "${behind:-0}" -gt 0 ]]; then
    [[ "$fetch_failed" = true ]] && echo "⚠️  $behind commits behind $default (stale)" || echo "⚠️  $behind commits behind $default"
  fi

  [[ -n "$GIT_HOOK" ]] && _tab_untracked || _tab_uncommitted
  _tab_commits
}

repos () { # List all repos # ➜ repos public
  [[ -n $1 ]] && gh repo list --visibility $1 || gh repo list
}

issue () { # Create or view gh issue # ➜ issue "update nginx security policy"
  [[ ! $1 ]] && gh issue list && return
  [[ ! $1 = *[[:alpha:]]* ]] && gh issue view $1 && return
  [[ $2 = [[:alpha:]]* ]] && body=$2 || body=$1
  issue=`gh issue create -t $1 -b $body`
  for i in "$@" ; do if [[ "$i" == "-"* ]] && gh issue view "${issue##*/}" --web; done;
}

secrets () {
  while IFS= read -r line; do
    key=$(echo "$line" | cut -d '=' -f 1)
    value=$(echo "$line" | cut -d '=' -f 2-)

    gh secret set $key -b"$value"

    sleep 1
  done < .env
}

workflows () { # Copy template workflow to repo # ➜ workflows test
  [[ ! -d .git ]] && git rev-parse --git-dir > /dev/null 2>&1 && cd $(git rev-parse --show-toplevel)
  local _dir=~/.templates/github-actions
  local app_name=$(basename $(pwd))

  display_workflows() {
    echo "Available workflows:"
    for file in "$_dir"/*.yml; do
      choice=$(basename "$file" .yml)
      echo "  $choice"
    done
  }

  if [ $# -eq 0 ]; then
    display_workflows
    return
  fi

  mkdir -p .github/workflows

  if [ -f "$_dir/$1.yml" ]; then
    cp -r $_dir/$1.yml .github/workflows
    sed -i "" -e "s/replace_with_app_name/${app_name}/g" ".github/workflows/$1.yml"
  fi

  tree .github/workflows
}

issues () { # List gh issues
  [[ $1 ]] && gh issue view $1 || gh issue list
}

 _releases_across_repos () {
  for i in */; do
    if [ -d "$i".git ]; then
       (
        cd "$i"
        local repo_name=$(basename $(git rev-parse --show-toplevel))
        local cyan_repo_name=$(ColorCyan $repo_name)
        echo $cyan_repo_name $(releases 1)
       )
    fi
  done
 }

releases () { # List releases for repo # ➜ releases 5
  if [ ! -d .git ]; then
    _releases_across_repos
    return
  fi
  [[ $1 ]] && no=$1 || no=500
  git for-each-ref --sort=-creatordate --format '%(refname:short) %(creatordate:relative)' refs/tags | head -n $no | awk '{tag = $1; date = $2 " " $3 " " $4 " " $5 " " $6; printf "\033[0;32m%-7s \033[1;0m%-s\n", tag, date}'
}

prs () { # List open prs
  if [ ! -d .git ]; then
    _allprs
    return
  fi
  [[ $1 ]] && gh pr view $1 || gh pr list
}

_allprs () {
  for i in */; do
    if [ -d "$i".git ]; then
      (cd "$i" && prs)
    fi
  done
}

branches () {
  echo $(git branch | wc -l) branches
  git branch
}

commits () { # List recent commits # ➜ commits 5
  if [ ! -d .git ]; then
    _commits_across_repos
    return
  fi
  local branch="$(git branch --show-current)"
  local default=$(_default_branch)
  if [[ $branch = $default ]]; then
    [[ $1 ]] && no=$1 || no=$(git rev-list --count $default)
    git log --pretty=format:"%ar %s" |head -$no | _colorize_commit_type
  else
    unique_to_branch=$(git rev-list --count $default..$branch)
    [[ $1 ]] && no=$1 || no=$(($unique_to_branch+1))
    git log $default.. --pretty=format:"%ar %s" | head -$no |  awk -v branch="$branch" '{print $0 " ➜ " branch}' | _colorize_commit_type
    if [[ $(($no-$unique_to_branch)) -gt 0  ]]; then
      git log $default --pretty=format:"%ar %s" | head -$(($no-$unique_to_branch)) |  awk -v branch=$default '{print $0 " ➜ " branch}' | _colorize_commit_type
    fi
  fi
}

_commits_across_repos () {
  [[ $1 ]] && no=$1 || no=2
  for i in */; do
    if [ -d "$i".git ]; then
     (
        cd "$i"
        repo_name=$(basename $(git rev-parse --show-toplevel))
        current_branch=$(git branch --show-current)
        cyan_repo_name=$(ColorCyan $repo_name)
        green_branch=$(ColorGreen $current_branch)
        echo $cyan_repo_name $green_branch
        echo "----------------"
        commits $no
        echo ""
      )
    fi
  done
}

repo() {
  local repo

  # Check if we're already in a GitHub repo
  if repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null); then
    echo "Updating settings for $repo..."
  else
    # Not in a repo, create one
    local owner="${1:-long-grass}"
    local name="$(basename "$PWD")"
    repo="$owner/$name"

    if ! gh api "users/$owner" &>/dev/null && ! gh api "orgs/$owner" &>/dev/null; then
      echo "Error: '$owner' does not exist or you don't have access"
      return 1
    fi

    if ! gh repo create "$repo" --source=. --private --remote=origin --push; then
      echo "Error: Failed to create repository"
      return 1
    fi

    echo "Created $repo"
  fi

  # Enable dependabot alerts and secret scanning push protection
  gh api -X PUT "/repos/$repo/vulnerability-alerts" --silent
  gh api -X PUT "/repos/$repo/secret-scanning/push-protection" --silent 2>/dev/null

  # Allow rebase and squash, disable merge commits, auto-delete branches
  gh api -X PATCH "/repos/$repo" \
    -f allow_merge_commit=false \
    -f allow_squash_merge=true \
    -f allow_rebase_merge=true \
    -f delete_branch_on_merge=true \
    --silent

  echo "Repo settings applied"
}

_getpr () {
  pr=$(gh pr list | grep `git branch --show-current` | awk -F' ' '{print $1}')
}

closepr () {
  _getpr
  gh pr close $pr
}

viewpr () {
  if [[ $1 ]] && [[ $1 == "b" ]]; then
    gh browse -b $(git branch --show-current)
    return
  fi
  [[ -n $1 ]] && pr=$1  || _getpr
  gh pr view $pr --web
  [[ $? == 1 ]] && gh browse -b $(git branch --show-current)
}

delete_old_branches () {
  local default=$(_default_branch)
  for branch in $(git branch | tr -d "* " | grep -v "^$default$"); do
    if [ -z "$(git log $default..$branch)" ]; then
      echo "Deleting branch $branch"
      git branch -d $branch
    fi
  done
}

_default_branch () {
  local branch=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's@^origin/@@')
  [[ -z "$branch" || "$branch" == "HEAD" ]] && branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  [[ -z "$branch" ]] && branch=$(git branch -l main master 2>/dev/null | head -1 | tr -d '* ')
  echo ${branch:-main}
}

unmerged () { # List unmerged commits # ➜ unmerged 5
  if [ ! -d .git ]; then
    _unmerged_commits_across_repos
    return
  fi
  local default=$(_default_branch)
  [[ $1 ]] && no=$1 || no=500 # List most recent unmerged commit in each branch
  for branch in $(git branch --sort=-authordate | tr -d "* " | grep -v "^$default$"); do
    if [ -n "$(git log $default..$branch)" ]; then
      no=$(git rev-list --count $default..$branch)
      date=$(git log -1 $branch --pretty=format:"%ar" --no-walk)
      message=$(git log -1 $branch --pretty=format:"%s" --no-walk)
      printf "$no $date $message $branch\n"
    fi
  done | head -$no | awk '{first = $1; date = $2 " " $3 " " $4; last = $NF; message = substr($0, length($1 $2 $3 $4) + 5, length($0) - length($1 $2 $3 $4 $NF) - 5); printf "\033[0;32m%-3s \033[1;0m%-15s \033[0;32m%-52s \033[0;36m%s\n", first, date, message, last}'
}

_unmerged_commits_across_repos () {
  for i in */; do
    if [ -d "$i".git ]; then
      (
        cd "$i"
        local output=$(unmerged 2)
        if [[ -n "$output" ]]; then
          local repo_name=$(basename $(git rev-parse --show-toplevel))
          local cyan_repo_name=$(ColorCyan $repo_name)
          echo $cyan_repo_name
          echo "----------------"
          echo $output
        fi
      )
    fi
  done
  [ -d .git ] && unmerged 5
}

rebase_branches () {
  local default=$(_default_branch)
  declare -a failed_rebase_branches

  git checkout $default
  git fetch

  for branch in $(git for-each-ref refs/heads/ --format '%(refname:short)' | grep -v "^$default$"); do

    common_ancestor=$(git merge-base "$default" "$branch")

    if [ "$common_ancestor" != "$(git rev-parse "$branch")" ]; then
      echo "Rebasing branch $branch"
      git checkout "$branch"
      if ! git rebase $default; then
        echo "Conflict occurred while rebasing $branch. Aborting rebase."
        git rebase --abort
        failed_rebase_branches+=("$branch")
      fi
    else
      echo "Branch $branch is already up-to-date with $default."
    fi
  done

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" != "$default" ]; then
    git checkout $default
  fi

  if [ ${#failed_rebase_branches[@]} -ne 0 ]; then
    echo "\nThe following branches couldn't be rebased due to conflicts:\n------"
    for failed_branch in "${failed_rebase_branches[@]}"; do
      echo "- $failed_branch"
    done
  fi
}

cleanpr () {
  git rebase origin/main
  git reset origin/main
  git add .
  git commit
  git push -f
  _format_pr_title $(git rev-parse --abbrev-ref HEAD)
  gh pr create --title "$modified_title" --body ""
  echo "#wip: " >  ~/.config/git/commit-msg-template
}

wip () { # Create work-in-progress commit # ➜ wip "Initial cities now shading correctly"
  echo "#wip: $1" > ~/.config/git/commit-msg-template
  git commit
}

fix () { # Create semver fix commit # ➜ fix "Add missing data for Daegu"
  echo "#fix: $1" > ~/.config/git/commit-msg-template
  git commit
}

docs () { # Create semver docs commit # ➜ docs "Add new blog post for new routes"
  echo "#docs: $1" > ~/.config/git/commit-msg-template
  git commit
}

minor () { # Create semver minor commit # ➜ minor "Colorize and tab output"
  echo "#feat: $1" > ~/.config/git/commit-msg-template
  git commit
}

major () { # Create semver major commit # ➜ major "Replace big breaking thing"
  echo "#feat: $1\n\nBREAKING CHANGE:" > ~/.config/git/commit-msg-template
  git commit
}

disallowed_commits () {
  local default=$(_default_branch)
  git cherry -v $default | grep -v -e fix -e feat -e docs
}

_colorize_commit_type () {
  sed -r -e "s/([a-zA-Z0-9]+(\([a-zA-Z0-9]+\))?:)/$(ColorCyan "\1")/" -e "s/(➜ .*)/$(ColorGreen "\1")/"
}

_format_pr_body () {
  git log main.. --pretty=%B | sed 's/^[a-zA-Z0-9_]*: //'
}

ghpr () { # Create and validate a PR
  if [[ $(disallowed_commits) ]]
    then
    echo please squash the following commits before submitting PR
    disallowed_commits
    return
  fi
  git push
  local pr=$(_getpr)
  local modified_title=$(_format_pr_title $(git branch --show-current))
  if [ $pr ]; then
    gh pr edit $pr --body "$(_format_pr_body)"
  else
    gh pr create --title "$modified_title" --body "$(_format_pr_body)"
  fi
}

card () {
  [[ ! $1 ]] && return
  _format_pr_title $1
  issue=$(gh issue create -t $modified_title -b "")
  num=$(echo $issue | awk -F'/' 'END{print $NF}')
  gh issue develop -c -n $1 $num
}

_format_pr_title () {
  if [[ $1 =~ -[0-9] ]]
    then
    input_string=$1

    # Extract the prefix and suffix
    prefix=$(echo "$input_string" | awk 'match($0, /[0-9]+/){ print substr($0, 1, RSTART-1) substr($0, RSTART, RLENGTH) }')
    suffix=$(echo "$input_string" | awk 'match($0, /[0-9]+/){ print substr($0, RSTART+RLENGTH) }')

    # Replace hyphens with spaces in the suffix
    modified_suffix=$(echo "$suffix" | awk '{gsub(/-/, " "); print}')

    # Concatenate the prefix and modified suffix, separated with a colon
    modified_title="${prefix}:${modified_suffix}"
  else
    modified_title=$(echo "$1" | awk '{gsub(/-/, " "); print}')
  fi
  echo $modified_title
}

update_hooks () { # Updates hooks for current repo
  cp -r ~/.config/git/hooks/* .git/hooks
}

_find_missing_newlines () {
  find . -type f -not -path "./.git*" -exec sh -c 'file -b "{}" | grep -q text' \; -exec sh -c '[ "$(tail -c 1 "{}" | od -An -a | tr -d "[:space:]")" != "nl" ]' \; -print
  find . -name '*.json' -exec sh -c '[ "$(tail -c 1 "{}" | od -An -a | tr -d "[:space:]")" != "nl" ]' \; -print
}

addnewlines () { # Add newlines where missing
  for i in $(_find_missing_newlines)
  do
    echo >> $i
  done
}

gtop () {
  cd $(git rev-parse --show-toplevel)
}

mv () { # git mv in repos, regular mv otherwise # ➜ mv old.txt new.txt
  if [[ "$1" != -* ]] && git rev-parse --is-inside-work-tree &>/dev/null \
    && { git ls-files --error-unmatch "$1" &>/dev/null || { [[ -d "$1" ]] && git ls-files -- "$1/" | read -r; }; }; then
    git mv "$@" 2>/dev/null || command mv "$@"
  else
    command mv "$@"
  fi
}

ginit () {
  git init
  if [ ! -f package.json ]
    then
    npm init -y
    npm pkg set scripts.dev="echo \"Error: no dev script specified\" && exit 1"
    npm pkg set scripts.build="echo \"Error: no build script specified\" && exit 1"
  fi
  if [ ! -d .github ]
    then
    mkdir -p .github/workflows
    cp ~/.templates/github-actions/test.yml .github/workflows
    cp ~/.templates/github-actions/release.yml .github/workflows
    git add .github
  fi
  if [ ! -f Makefile ]
    then
    cp -r  ~/.templates/makefiles .
    cp -r  ~/.templates/Makefile .
    git add Makefile makefiles
  fi
  if [ ! -f .gitignore ]
    then
    cp -r ~/.config/git/ignore .gitignore
    git add .gitignore
  fi
  if [ ! -f README.md ]
    then
    cp -r ~/.templates/README.md .
    git add README.md
  fi
  if [ ! -f .vscode/settings.json ]
    then
    mkdir -p .vscode
    cp -r ~/Library/Application\ Support/Code/User/settings.json .vscode/settings.json
  fi
  g add .
  g commit -m "feat: initialized repo"
}

ghlist () { # List GitHub orgs and personal account # ➜ ghlist
  gh api user --jq '.login'
  gh api user/orgs --jq '.[].login'
}

ghcreate () { # Create private repo on GitHub org # ➜ ghcreate [org] [name]
  local org="${1:-long-grass}"
  local name="${2:-$(basename "$PWD")}"
  [[ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" != "main" ]] && echo "Not on main" && return 1
  [[ -z "$(git log --oneline -1 2>/dev/null)" ]] && echo "No commits" && return 1
  [[ -n "$(git status --porcelain 2>/dev/null)" ]] && echo "Untracked or uncommitted files" && return 1
  gh repo create "$org/$name" --private --source=. --remote=origin --push
}

highest() { # Find highest numbered branch with prefix # ➜ highest rk
  if [ -z "$1" ]; then
    echo "Usage: highest <prefix>"
    return 1
  fi
  local prefix="$1"
  git log --all --oneline | grep -i "${prefix}-" | \
    sed -E "s/.*${prefix}-([0-9]+).*/\1/I" | \
    sort -rn | head -1
}

grk() { # Create branch with auto-incrementing number # ➜ grk my-feature
  if [ -z "$1" ]; then
    echo "Usage: grk <branch-description>"
    return 1
  fi
  local next_number=$(($(highest rk) + 1))
  local branch_name="rk-${next_number}-${1}"
  git br "${branch_name}"
}

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
  cd $(git rev-parse --show-toplevel)
  local _dir=~/.zsh/templates/github-actions
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
  git for-each-ref --sort=taggerdate --format '%(refname:short) %(taggerdate:relative)' refs/tags | grep ago | sort -V | tail -n $no |awk '{tag = $1; date = $2 " " $3 " " $4 " " $5 " " $6; printf "\033[0;32m%-7s \033[1;0m%-s\n", tag, date}'
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

repo () { # create repo with settings
  if [ ! -d .git ]; then
    echo "current directory is not a git repository. Run git init to create one"
    return
  fi
  local repo_name=${1:-$(basename $(pwd))}
  local visibility="private"
  local username=$(git config --global user.name)

  if [[ -z "$repo_name" || -z "$visibility" || -z "$username" ]]; then
    return 1
  fi

  gh repo create "$repo_name" --"$visibility"

  gh api -X PATCH "repos/$username/$repo_name" \
    -F allow_merge_commit=false \
    -F allow_squash_merge=false \
    -F delete_branch_on_merge=true

  gh api repos/$username/$repo_name -X GET | jq
  set_secret
  git remote add origin git@github.com:$username/$repo_name.git
  git push origin main
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
  if [ ! -f .git/refs/remotes/origin/HEAD ]; then
    local branch="main"
  else
    local branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  fi
  echo $branch
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

ginit () {
  git init
  if [ ! -f package.json ]
    then
    npm init -y
  fi
  if [ ! -d .github ]
    then
    mkdir -p .github/workflows
    cp ~/.zsh/templates/github-actions/test.yml .github/workflows
    cp ~/.zsh/templates/github-actions/release.yml .github/workflows
    git add .github
  fi
  if [ ! -f Makefile ]
    then
    cp -r  ~/.zsh/templates/Makefile .
    git add Makefile
  fi
  if [ ! -f .gitignore ]
    then
    cp -r ~/.config/git/ignore .gitignore
    git add .gitignore
  fi
  if [ ! -f README.md ]
    then
    cp -r ~/.zsh/templates/README.md .
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

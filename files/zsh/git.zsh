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

issues () { # List gh issues
  [[ $1 ]] && gh issue view $1 || gh issue list
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

repo () { # View repo settings or set to defaults ➜ repo --defaults
  if [ ! -d .git ]; then
    echo "current directory is not a git repository. Run git init to create one"
    return
  fi
  if [ $(git remote | wc -l) -eq 0 ]; then
    gh repo create
    local created=true
  fi
  if [ $(git remote | wc -l) -eq 0 ]; then
    echo "repo didn't create"
    return
  fi
  REPO_URL=$(git remote -v | grep -o 'git@github.com:[^ ]*' | head -n 1)
  OWNER=$(echo "$REPO_URL" | cut -d ':' -f 2 | cut -d '/' -f 1)
  REPO=$(echo "$REPO_URL" | cut -d '/' -f 2 | cut -d '.' -f 1)
  if [[ $# -gt 0 || $created ]]; then
    settings="-F allow_merge_commit=false "
    settings+="-F allow_squash_merge=false "
    settings+="-F delete_branch_on_merge=true"
    gh api repos/$OWNER/$REPO -X PATCH -F $settings | jq
    echo "Following settings applied:"
    echo "-------------------------"
    echo $settings | awk -F '-F ' '{ for (i=2; i<=NF; i++) print $i }' | awk -F '=' '{print $1"="$2}'
  else
    gh api repos/$OWNER/$REPO -X GET | jq
  fi
}

_getpr () {
  pr=$(gh pr list | grep `git branch --show-current` | awk -F' ' '{print $1}')
}

closepr () {
  _getpr
  gh pr close $pr
}

viewpr () {
  [[ $1 ]] && pr=$1 || _getpr
  gh pr view $pr --web
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
	echo "#feat!: $1" > ~/.config/git/commit-msg-template
	git commit
}

disallowed_commits () {
  local default=$(_default_branch)
  git cherry -v $default | grep -v -e fix -e feat -e docs
}

_colorize_commit_type () {
  sed -r -e "s/([a-zA-Z0-9]+(\([a-zA-Z0-9]+\))?:)/$(ColorCyan "\1")/" -e "s/(➜ .*)/$(ColorGreen "\1")/"
}

ghpr () { # Create and validate a PR
  if [[ $(disallowed_commits) ]]
    then
    echo please squash the following commits before submitting PR
    disallowed_commits
  else
    git push
    _format_pr_title $(git branch --show-current)
    gh pr create --title "$modified_title" --body ""
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

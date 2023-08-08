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
  [[ $1 ]] && gh pr view $1 || gh pr list
}

allprs () { # List open prs in all projects
  for i in */; do
    if [ -d "$i".git ]; then
      (cd "$i" && prs)
    fi
  done
  [ -d .git ] && prs
}

commits () { # List recent commits # ➜ commits 5
  if [ ! -d .git ]; then
    _commits_across_repos
    return
  fi
  [[ $1 ]] && no=$1 || no=500
  branch="$(git branch --show-current)"
  if [[ $branch = 'main' ]]; then
    git log --pretty=format:"%h %ad %s" --date=format:"%b-%d" | head -$no |  awk '{$1=""; print $0}' | _colorize_commit_type
  else
    unique_to_branch=$(git rev-list --count main..$branch)
    git log main.. --pretty=format:"%h %ad %s" --date=format:"%b-%d" | head -$no |  awk -v branch="$branch" '{$1=""; print $0 " ➜ " branch}' | _colorize_commit_type
    if [[ $(($no-$unique_to_branch)) -gt 0  ]]; then
      git log main --pretty=format:"%h %ad %s" --date=format:"%b-%d" | head -$(($no-$unique_to_branch)) |  awk -v branch="main" '{$1=""; print $0 " ➜ " branch}' | _colorize_commit_type
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
  for branch in $(git branch | grep -v 'main'); do
    if [ -z "$(git log main..$branch)" ]; then
      echo "Deleting branch $branch"
      git branch -d $branch
    fi
  done
}

unmerged () { # List unmerged commits # ➜ unmerged 5
  if [ ! -d .git ]; then
    _unmerged_commits_across_repos
    return
  fi
  [[ $1 ]] && no=$1 || no=500 # List most recent unmerged commit in each branch
  for branch in $(git branch --sort=-authordate | grep -v 'main'); do
    if [ -n "$(git log main..$branch)" ]; then
      no=$(git rev-list --count main..$branch)
      commit_info=$(git log -1 $branch --pretty=format:"%h %ad %s" --date=format:"%b-%d" --no-walk | awk '{$1=""; print $0}')
      printf "$no $commit_info $branch\n"
    fi
  done | head -$no | awk '{first = $1; date = $2; $1 = $2 = ""; last = $NF; $NF = ""; printf "\033[0;32m%-3s \033[1;0m%-8s \033[0;32m%-52s \033[0;36m%s\n", first, date, $0, last}'
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
  git cherry -v main | grep -v -e fix -e feat -e docs
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

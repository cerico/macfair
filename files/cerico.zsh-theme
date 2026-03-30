_update_pdir() {
  if [[ "$PWD" == "$HOME/worktrees/"* ]]; then
    local rel="${PWD#$HOME/worktrees/}"
    _pdir="${rel%%/*}:wt"
  else
    _pdir="${PWD##*/}"
  fi
}
add-zsh-hook precmd _update_pdir

PROMPT='%{$fg_bold[cyan]%}☁ %m%{$reset_color%}:%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})${_pdir} ➜%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "

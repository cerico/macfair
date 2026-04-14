_pdir="${PWD##*/}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗ "
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "

_update_pdir() {
  if [[ "$PWD" == "$HOME/worktrees/"* ]]; then
    local rel="${PWD#$HOME/worktrees/}"
    _pdir="${rel%%/*}:wt"
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}[%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}] %{$fg[yellow]%}✗ "
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}] "
  else
    _pdir="${PWD##*/}"
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗ "
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) "
  fi
}
add-zsh-hook precmd _update_pdir

PROMPT='%{$fg_bold[cyan]%}☁ $USER@%m%{$reset_color%}:%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})${_pdir} ➜%{$reset_color%} $(_short_git_prompt_info)'

ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

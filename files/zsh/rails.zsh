export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

logify () {
  cpr logging
  tail -f log/development.log
  cpr v
}

railsc () {
  cpr railsc
  rails c
  cpr v
}

railshist () {
  echo 'puts Readline::HISTORY.entries.each { |c| puts c }' | spring rails c | grep $1
}

rn () {
  rails new "$1" --database=postgresql "${@:2}"
}

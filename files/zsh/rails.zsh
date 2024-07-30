export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init - zsh)"

alias rgm="rails g model"
alias rgc="rails g controller"
alias rgs="rails g scaffold"
alias rr="rails routes --expanded"
alias rc="rails console"
alias migrate="rails db:migrate"

secret_key_base () {
  gh secret set RAILS_SECRET_KEY_BASE -b $(rails secret)
}

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

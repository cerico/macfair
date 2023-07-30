export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init - zsh)"

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

railsn () {
  make -f ~/Work/ansible/finisterre/Makefile rails -C ~/Work/ansible/finisterre LOCATION=`pwd`
}

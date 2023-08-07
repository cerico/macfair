_run() {
  local cmd=$1
  shift
  echo "Running $cmd $@"
  (
    trap 'exit' ERR
    $cmd $@
  )
  local exit_status=$?
  if [ $exit_status -ne 0 ]; then
    echo "Command failed: $cmd"
    return $exit_status
  fi
}

run_all_functions () {
  local host=$(hostname)

  if [ "$host" != "github-runner" ]; then
    echo "Only to be run in github action"
    return 1
  fi

  _run addmake
  _run astros 5
  _run city 71.4.1.7
  _run ColorGreen "I am green"
  _run ColorCyan "I am cyan"
  _run gits
  _run mark runner .
  _run marks
  _run upsearch Makefile
  _run recent Makefile 5
  _run commits
  _run mi
  _run functions
}

# GSD (Get Shit Done) convenience wrappers
# Usage: gsd <command> [args]

# Reclaim from git-svn plugin
unalias gsd 2>/dev/null

gsd() {
  local cmd="${1:-help}"
  shift 2>/dev/null

  case "$cmd" in
    help|--help|-h)
      cat <<'EOF'
Usage: gsd <command> [args]

Commands:
  new             Start new project (/gsd:new-project)
  milestone [n]   Start new milestone (/gsd:new-milestone [name])
  map [area]      Map existing codebase (/gsd:map-codebase [area])
  discuss [N]     Discuss a phase (/gsd:discuss-phase N)
  plan [N]        Plan a phase (/gsd:plan-phase N)
  exec [N]        Execute a phase (/gsd:execute-phase N)
  verify [N]      Verify work (/gsd:verify-work N)
  resume          Resume work (/gsd:resume-work)
  pause           Pause work (/gsd:pause-work)
  progress        Check progress (/gsd:progress)
  add [desc]      Add a todo (/gsd:add-todo [desc])
  todos           Check todos (/gsd:check-todos)
  debug [desc]    Debug an issue (/gsd:debug [desc])
EOF
      ;;

    new)
      claude "/gsd:new-project"
      ;;

    milestone)
      claude "/gsd:new-milestone $*"
      ;;

    map)
      claude "/gsd:map-codebase $*"
      ;;

    discuss)
      claude "/gsd:discuss-phase $*"
      ;;

    plan)
      claude "/gsd:plan-phase $*"
      ;;

    exec|execute)
      claude "/gsd:execute-phase $*"
      ;;

    verify)
      claude "/gsd:verify-work $*"
      ;;

    resume)
      claude "/gsd:resume-work"
      ;;

    pause)
      claude "/gsd:pause-work"
      ;;

    progress|status)
      claude "/gsd:progress"
      ;;

    add)
      claude "/gsd:add-todo $*"
      ;;

    todos)
      claude "/gsd:check-todos"
      ;;

    debug)
      claude "/gsd:debug $*"
      ;;

    *)
      echo "Unknown command: $cmd"
      echo "Run 'gsd help' for usage."
      return 1
      ;;
  esac
}

# Completion
_gsd() {
  local commands="new milestone map discuss plan exec verify resume pause progress add todos debug help"
  _arguments "1:command:($commands)"
}
compdef _gsd gsd 2>/dev/null

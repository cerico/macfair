# MCP server management
# Add MCP servers to current project (not globally)

mcp() {
  local action="$1"
  local server="$2"

  case "$action" in
    -a)
      [[ -z "$server" ]] && {
        echo "Usage: mcp -a <server>"
        echo "Available: mapbox, trello, sentry, stripe, github"
        return 1
      }
      case "$server" in
        mapbox)
          [[ -z "$MAPBOX_ACCESS_TOKEN" ]] && { echo "Error: MAPBOX_ACCESS_TOKEN not set"; return 1; }
          claude mcp add -s project mapbox -e MAPBOX_ACCESS_TOKEN="$MAPBOX_ACCESS_TOKEN" -- npx -y @mapbox/mcp-server
          ;;
        trello)
          [[ -z "$TRELLO_API_KEY" ]] && { echo "Error: TRELLO_API_KEY not set"; return 1; }
          [[ -z "$TRELLO_TOKEN" ]] && { echo "Error: TRELLO_TOKEN not set"; return 1; }
          claude mcp add -s project trello -e TRELLO_API_KEY="$TRELLO_API_KEY" -e TRELLO_TOKEN="$TRELLO_TOKEN" -- npx -y @modelcontextprotocol/server-trello
          ;;
        sentry)
          [[ -z "$SENTRY_AUTH_TOKEN" ]] && { echo "Error: SENTRY_AUTH_TOKEN not set"; return 1; }
          claude mcp add -s project sentry -e SENTRY_AUTH_TOKEN="$SENTRY_AUTH_TOKEN" -- npx -y @sentry/mcp-server
          ;;
        stripe)
          [[ -z "$STRIPE_SECRET_KEY" ]] && { echo "Error: STRIPE_SECRET_KEY not set"; return 1; }
          claude mcp add -s project stripe -e STRIPE_SECRET_KEY="$STRIPE_SECRET_KEY" -- npx -y @stripe/mcp
          ;;
        github)
          [[ -z "$GITHUB_TOKEN" ]] && { echo "Error: GITHUB_TOKEN not set"; return 1; }
          claude mcp add -s project github -e GITHUB_TOKEN="$GITHUB_TOKEN" -- npx -y @modelcontextprotocol/server-github
          ;;
        *)
          echo "Unknown server: $server"
          echo "Available: mapbox, trello, sentry, stripe, github"
          return 1
          ;;
      esac
      ;;
    -r)
      [[ -z "$server" ]] && { echo "Usage: mcp -r <server>"; return 1; }
      claude mcp remove -s project "$server"
      ;;
    *)
      claude mcp list
      ;;
  esac
}

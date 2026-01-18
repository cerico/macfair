export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=30

diskfree () {
  df -h / | awk 'NR==2 {print $4 " free of " $2}'
}

disktop () {
  du -sh ~/Library/Caches ~/.cache ~/.local/share 2>/dev/null | sort -hr
}

diskclean () {
  echo "Before: $(diskfree)"

  echo "Cleaning uv cache..."
  rm -rf ~/.cache/uv 2>/dev/null

  echo "Cleaning pip cache..."
  rm -rf ~/Library/Caches/pip 2>/dev/null

  echo "Cleaning Homebrew..."
  brew cleanup --prune=all 2>/dev/null

  echo "Cleaning go cache..."
  go clean -cache 2>/dev/null

  echo "Cleaning pnpm store..."
  pnpm store prune 2>/dev/null

  echo "Cleaning npm cache..."
  npm cache clean --force 2>/dev/null

  echo "Cleaning container caches..."
  rm -rf ~/Library/Caches/lima 2>/dev/null
  podman system prune -af 2>/dev/null

  echo "Cleaning electron app caches..."
  rm -rf ~/Library/Caches/com.todesktop*(N) 2>/dev/null
  rm -rf ~/Library/Caches/sh.tight.voice-code 2>/dev/null

  echo "Cleaning browser caches..."
  rm -rf ~/Library/Caches/Vivaldi 2>/dev/null
  rm -rf ~/Library/Caches/Firefox 2>/dev/null
  rm -rf ~/Library/Caches/zen 2>/dev/null
  rm -rf ~/Library/Caches/org.user.kagiBrowser 2>/dev/null

  echo "After: $(diskfree)"
}

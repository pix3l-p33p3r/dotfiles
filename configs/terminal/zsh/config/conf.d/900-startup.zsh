# fastfetch on every new Kitty window/tab (and top-level non-Kitty shells).
# Skip dumb terminals (Cursor agent, IDE) and nested shells that inherit FASTFETCH_SHOWN.
if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -z "${FASTFETCH_SHOWN:-}" ]] && command -v fastfetch >/dev/null; then
  if [[ -n "${KITTY_WINDOW_ID:-}" || "${SHLVL}" -eq 1 ]]; then
    export FASTFETCH_SHOWN=1
    fastfetch
  fi
fi

# direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# atuin
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# zoxide - must be last
if command -v zoxide >/dev/null; then
  export _ZO_DOCTOR=0
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# Run fetch on each top-level shell session
if [ "$SHLVL" = "1" ] && command -v fastfetch >/dev/null
then
  fastfetch
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

# Run fetch on each grandfather shell session
if [ "$SHLVL" = "1" ]
then
  # fastfetch
  macchina

  # Load SSH key into the agent once per session (no-op if already loaded).
  # SSH_AUTH_SOCK is exported via home.sessionVariables; ssh-add -l exits 1 when
  # the agent is reachable but has no identities, and 2 when it can't connect.
  if [[ -S "$SSH_AUTH_SOCK" ]]; then
    ssh-add -l &>/dev/null || ssh-add ~/.ssh/id_ed25519 2>/dev/null
  fi
fi

# direnv
eval "$(direnv hook zsh)"

# atuin
eval "$(atuin init zsh)"

# zoxide - must be last
export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"

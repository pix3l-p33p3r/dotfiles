# Run fetch on each grandfather shell session
if [ "$SHLVL" = "1" ]
then
  fastfetch
  # macchina
fi

# direnv
eval "$(direnv hook zsh)"

# atuin
eval "$(atuin init zsh)"

# zoxide - must be last
export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"

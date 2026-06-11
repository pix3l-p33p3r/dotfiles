# gpg-agent pinentry needs the active TTY (git -S, commits, clearsign, etc.)
if [[ -t 0 && -t 1 ]]; then
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

# TTY can change (tmux panes, new tabs); refresh before each prompt.
gpg_refresh_tty() {
  if [[ -t 0 && -t 1 ]]; then
    export GPG_TTY=$(tty)
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd gpg_refresh_tty

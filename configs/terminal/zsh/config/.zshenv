# Cluster-adapted from pix3l-p33p3r/dotfiles (Home Manager optional on 1337)
if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Only source this once
if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]; then
  export __HM_ZSH_SESS_VARS_SOURCED=1
fi

export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"
export WORDCHARS=${WORDCHARS//\//}

# Include volta in path
export VOLTA_HOME="$XDG_DATA_HOME/volta"

# Go path
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE="$XDG_CACHE_HOME/go"
export GOBIN="$GOPATH/bin"

# Cargo / Rustup path
if [[ -d "${GOINFRE:-/goinfre/$USER}/cargo/bin" ]]; then
  export CARGO_HOME="${GOINFRE:-/goinfre/$USER}/cargo"
  export RUSTUP_HOME="${GOINFRE:-/goinfre/$USER}/rustup"
else
  export CARGO_HOME="$XDG_DATA_HOME/cargo"
fi

# Deno path
export DENO_DIR="$XDG_CACHE_HOME/deno"
export npm_config_cache="${GOINFRE:-/goinfre/$USER}/npm"

# Custom nix profile has bin/ but no etc/profile.d/nix.sh — add explicitly
export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$HOME/.ghcup/bin:$GOBIN:$CARGO_HOME/bin:$VOLTA_HOME/bin:$PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export VISUAL='nvim --clean'
  export EDITOR='nvim --clean'
else
  export EDITOR="${EDITOR:-nvim}"
  export VISUAL="${VISUAL:-nvim}"
fi

# Repl's History files
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"
export DENO_REPL_HISTORY="$XDG_CACHE_HOME/deno_repl_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonstartup.py"
export REDISCLI_HISTFILE="$XDG_CACHE_HOME/rediscli_history"

# Curl
export CURL_HOME="$XDG_CONFIG_HOME/curl"

# Timezsh start
if [ -n "${ZSH_DEBUGRC+1}" ]; then zmodload zsh/zprof; fi

# 1337: (re)build this machine's goinfre setup. Defined before Zap so it exists
# on a fresh machine where plugins and Nix are still missing.
[[ -d /goinfre ]] && alias nix-up="$HOME/dotfiles-terminal/homes/elel-yak/bootstrap/install.sh && $HOME/.local/bin/goinfre-heal --force"

# Ensuring Zap installed (--keep: never overwrite this .zshrc; goinfre can wipe plugins)
if [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]]; then
  _zap_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zap"
  git clone --depth 1 --branch release-v1 https://github.com/zap-zsh/zap.git "$_zap_dir" \
    || zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
  unset _zap_dir
fi

source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Loading config files (bindings that need plugins are deferred — see after plugs)
for FILE in $(
  find "$ZDOTDIR/conf.d/" \( -type f -o -type l \) -name '*.zsh' -exec basename {} \; | sort -n
); do
  # Plugin-dependent keybinds must run after plugs define ZLE widgets
  [[ "$FILE" == "103-bindings.zsh" ]] && continue
  source "$ZDOTDIR/conf.d/$FILE"
done

plug "zsh-users/zsh-autosuggestions"
plug "agkozak/agkozak-zsh-prompt"
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-history-substring-search"
plug "jeffreytse/zsh-vi-mode"
plug "wazum/zsh-directory-dot-expansion"
plug "hlissner/zsh-autopair"
plug "kutsan/zsh-system-clipboard"
# Must load before calc — calc defines alias '=' which breaks highlighter bootstrap
plug "zsh-users/zsh-syntax-highlighting"
plug "arzzen/calc.plugin.zsh"

# Now that widgets exist, apply keybinds
[[ -f "$ZDOTDIR/conf.d/103-bindings.zsh" ]] && source "$ZDOTDIR/conf.d/103-bindings.zsh"

# Adding local completions to fpath
fpath+=($ZDOTDIR/completions)

autoload -Uz compinit
_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# #q expands globs in conditional expressions
if [[ $_comp_path(#qNmh-20) ]]; then
  # -C (skip function check) implies -i (skip security check).
  compinit -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
  # Keep $_comp_path younger than cache time even if it isn't regenerated.
  touch "$_comp_path"
fi
unset _comp_path

# Carapace completions
command -v carapace >/dev/null && source <(carapace _carapace)

# Timezsh end
if [ -n "${ZSH_DEBUGRC+1}" ]; then zprof; fi

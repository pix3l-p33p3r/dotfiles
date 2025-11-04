# ls
local ls=eza
alias eza="$ls --icons"
alias {l,ls}="$ls"
alias lsa="$ls -lah"
alias ll="$ls -lh"

# Stack
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# to check if vpn works
alias myip="curl icanhazip.com"

# Sanity flags
alias cp="cp -ri"
alias rm="rm -i"
alias df='df -h'
alias makej="make -j \`nproc\`"
alias cat="bat --plain"
alias cd="z"
alias grep="grep --color=auto"
alias mkdir="mkdir -p"

alias o="xdg-open"
alias tm=tmux
alias path='echo -e ${PATH//:/\\n}'
alias pg="ping 1.0.0.1 -c 5"
alias vi=nvim
alias e="$EDITOR"

# nix aliases
alias clean="$HOME/dotfiles/scripts/nix-cleaner.sh"

alias update="nix flake update && fastfetch"

# NixOS system rebuild (optimized for speed)
alias nrs="sudo nixos-rebuild switch --flake '$HOME/dotfiles#alucard' --no-reexec --no-build-output"

# Home Manager rebuild (optimized for speed)
alias hms="home-manager switch --flake '$HOME/dotfiles#pixel-peeper@alucard'"

alias update="cd $HOME/dotfiles && nix flake update && nrs && hms && clean && fastfetch"

# Full upgrade: update flake, rebuild system and home-manager, then clean
alias upgrade="cd $HOME/dotfiles && nrs && hms && clean && fastfetch"

alias check="nix flake check"

# extra nix helpers
alias nsize="nix path-info -Sh /run/current-system"
alias nsearch="nix search nixpkgs"
alias nwhy="nix why-depends"
alias nfdiff="nix flake diff"
alias nbuild="cd $HOME/dotfiles && nix build .#"
alias mcp="nix run github:utensils/mcp-nixos"


alias timezsh="time ZSH_DEBUGRC=1 zsh -i -c exit"

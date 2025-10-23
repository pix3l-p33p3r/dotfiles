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
alias zlj=zellij
alias tx=tmux
alias path='echo -e ${PATH//:/\\n}'
alias pg="ping 1.0.0.1 -c 5"
alias vi=nvim
alias e="$EDITOR"

# nix aliases

alias build="sudo nixos-rebuild switch --flake . && home-manager switch --flake ."
alias clean="./scripts/nix-cleaner.sh"



alias timezsh="time ZSH_DEBUGRC=1 zsh -i -c exit"

# ── ls / eza ──────────────────────────────────────────────────────────────
local ls=eza
alias eza="$ls --icons"
alias {l,ls}="$ls"
alias lsa="$ls -lah"
alias ll="$ls -lh"

# ── Directory stack ────────────────────────────────────────────────────────
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# ── Sanity flags ───────────────────────────────────────────────────────────
alias cp="cp -ri"
alias rm="rm -i"
alias df='df -h'
alias makej="make -j \`nproc\`"
alias cat="bat --plain"
alias cd="z"
alias grep="grep --color=auto"
alias mkdir="mkdir -p"

# ── General shortcuts ──────────────────────────────────────────────────────
alias o="thunar ."
alias tm=tmux
alias path='echo -e ${PATH//:/\\n}'
alias pg="ping 1.0.0.1 -c 5"
alias myip="curl icanhazip.com"
alias vi=nvim
alias e="$EDITOR"

# ── Debug ─────────────────────────────────────────────────────────────────
alias timezsh="time ZSH_DEBUGRC=1 zsh -i -c exit"
alias nrs='sudo nixos-rebuild switch --flake .#alucard'

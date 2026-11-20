# ── ls / eza ──────────────────────────────────────────────────────────────
# (no `local` here — this file is sourced at top level)
_ls_cmd=eza
alias eza="${_ls_cmd} --icons"
alias l="${_ls_cmd}"
alias ls="${_ls_cmd}"
alias lsa="${_ls_cmd} -lah"
alias ll="${_ls_cmd} -lh"
unset _ls_cmd

# ── Directory stack ────────────────────────────────────────────────────────
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# ── Sanity flags ───────────────────────────────────────────────────────────
alias cp="cp -ri"
alias rm="rm -i"
alias df='df -h'
alias makej="make -j \`nproc\`"
alias cat="bat --plain"
# cd→z applied in 900-startup.zsh after zoxide init
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

# ── Lazy TUIs (`lD`/`lS` — `ld` is the linker, `ls` is eza) ───────────────
alias lg=lazygit
alias lD=lazydocker
alias lh=lazyhetzner
alias lj=lazyjournal
alias lS=lazysql

# ── Debug ─────────────────────────────────────────────────────────────────
alias timezsh="time ZSH_DEBUGRC=1 zsh -i -c exit"
# ── Security scanning (store binary from homes/pixel-peeper/cli.nix) ─────
unalias secscan aidechk lynischk vulnchk 2>/dev/null
alias aidechk='secscan aide'
alias lynischk='secscan lynis'
alias vulnchk='secscan vulnix'

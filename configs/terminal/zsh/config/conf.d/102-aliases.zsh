# ── ls / eza ──────────────────────────────────────────────────────────────
# Fall back to /bin/ls when the nix store is not mounted (outside nix-enter).
if command -v eza >/dev/null 2>&1 && eza --version >/dev/null 2>&1; then
  alias eza='command eza --icons=always'
  alias l='command eza --icons=always'
  alias ls='command eza --icons=always'
  alias lsa='command eza --icons=always -lah'
  alias ll='command eza --icons=always -lh'
else
  alias l='/bin/ls --color=auto'
  alias ls='/bin/ls --color=auto'
  alias lsa='/bin/ls -lah --color=auto'
  alias ll='/bin/ls -lh --color=auto'
fi

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

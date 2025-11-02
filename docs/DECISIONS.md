# Tooling Decisions

Key decisions about tools and technologies used (or not used) in this dotfiles configuration.

---

## Git vs Jujutsu (jj)

### Decision: Stick with Git

I evaluated `jj` (Jujutsu), a modern Git-compatible VCS, but decided to stick with Git.

### Why?

**My Setup:**
- Small dotfiles repository - Git handles it perfectly
- Solo development - no complex merge conflicts
- Existing workflow with `lazygit`, Neovim plugins, GitHub CLI
- Nix/Flakes ecosystem expects Git

**Pros of jj:**
- Better conflict handling
- Automatic snapshots
- Faster on large repos (10k+ files)
- Git compatible

**Cons for my use case:**
- Learning curve with limited benefit
- Ecosystem incompatibility (`lazygit`, Neovim plugins)  
- Maintenance overhead (need to know both tools)
- NixOS ecosystem assumes Git

**ROI:** Low to negative for dotfiles; might reconsider for large monorepos.

---

## Home Manager: Standalone vs Integrated

### Decision: Standalone Home Manager

I chose to run Home Manager independently from NixOS system configuration.

### Why?

**Speed:**
- User environment rebuilds in 30 seconds (vs 5+ minutes integrated)
- No sudo needed for most daily changes
- Fast iteration encourages experimentation

**Separation:**
- Clear boundary between system and user config
- Independent rollbacks (break user config without affecting system)
- Safer experimentation

**Workflow:**
```bash
sudo nixos-rebuild switch --flake .#alucard     # System
home-manager switch --flake .#pixel-peeper@alucard  # User
# Or: upgrade (does both + cleanup)
```

**Trade-offs:**
- Two commands instead of one (mitigated by aliases)
- Need to coordinate flake updates
- Less common pattern (most tutorials use integrated)

**ROI:** High for actively developed configs; would use integrated for set-and-forget servers.

---

**For practical guides, see:**
- Home Manager usage: `docs/HOME-MANAGER.md`
- Secrets management: `secrets/README.md`
- Font configuration: `docs/FONTS.md`


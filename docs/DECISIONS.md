# Tooling Decisions

This document records key decisions about tools and technologies used (or not used) in my dotfiles configuration, along with the reasoning behind each choice.

---

## Version Control: Why I Use Git Instead of `jj` (Jujutsu)

### The Question

I recently evaluated whether to add `jj` (Jujutsu), a modern Git-compatible version control system, to my development setup. After careful consideration, I decided to stick with Git.

### What is `jj`?

`jj` (Jujutsu) is a Git-compatible version control system that aims to improve upon Git's workflow with:

- **Better conflict handling** - Superior merge conflict detection and resolution
- **Automatic snapshotting** - No need to commit before switching branches
- **Performance improvements** - Faster operations on large repositories
- **Git compatibility** - Can work alongside Git and push to Git remotes

### My Current Setup

I'm currently using:
- **Git** with standard tooling (`git`, `git-lfs`, `git-crypt`, `git-secrets`)
- **GitHub/GitLab CLIs** (`gh`, `glab`) for workflow automation
- **lazygit** for a TUI interface when I need visual git operations
- **Neovim Git plugins** (`gitsigns`) that integrate with Git

This setup works well for my needs, especially for managing my NixOS dotfiles repository.

### ROI Analysis

#### For My Dotfiles Repository

**ROI: Low to Negative**

My dotfiles repository is relatively small and well-structured. Git handles it perfectly fine:
- Small repository size means Git's performance is already excellent
- Infrequent conflicts due to solo development
- Simple branching strategy
- The time investment to learn `jj` wouldn't provide meaningful benefits here

#### For Larger/Team Projects

**ROI: Medium to High**

If I were working on large monorepos or frequently dealing with complex merge conflicts, `jj` might offer better value. However, that's not my current use case.

### Pros of `jj`

1. **Better Conflict Handling**: Superior merge conflict detection and resolution, which would be valuable on complex branches
2. **Automatic Snapshots**: No need to commit before switching branches - great for experimental work
3. **Performance**: Faster on very large repositories (10k+ files)
4. **Git Compatibility**: Can coexist with Git workflows and push to GitHub/GitLab
5. **Modern UX**: Better CLI output and more intuitive commands than Git

### Cons of `jj`

1. **Learning Curve**: New commands to learn (`jj commit`, `jj rebase`, etc.) and a different mental model (operations vs. snapshots)
2. **Ecosystem Incompatibility**: 
   - `lazygit` doesn't support `jj`
   - Neovim Git plugins (`gitsigns`) target Git specifically
   - Most CI/CD pipelines expect Git
   - `gh`/`glab` CLIs expect Git workflows
3. **Team Collaboration**: Others would need to learn `jj` or rely on Git compatibility layer, adding friction
4. **NixOS/Nix Ecosystem**: Most Nix configurations assume Git, and flakes/tooling expect Git workflows
5. **Maturity**: Newer tool with smaller community and fewer resources compared to Git
6. **Maintenance Overhead**: Would need to maintain knowledge of both `git` and `jj` workflows

### My Decision

**I'm not adding `jj` to my setup.**

For my NixOS dotfiles repository specifically:
- **Small, manageable repository** - Git handles it perfectly
- **Solo development** - No complex merge conflicts
- **Existing Git workflow works well** - Git + lazygit + gh/glab covers all my needs
- **Nix/Flakes ecosystem expects Git** - Better compatibility with existing tooling

The learning curve and ecosystem incompatibilities outweigh the potential benefits for my use case. Git is working fine, and there's no compelling reason to switch.

### When I Might Reconsider

I would consider adding `jj` if:
- I start working on large monorepos with 10k+ files regularly
- I frequently encounter complex merge conflicts that Git struggles with
- I work with teams that have adopted `jj`
- `jj` gains broader ecosystem support (especially for Neovim and lazygit)

For now, Git remains the right tool for the job.

---

## Home Manager: Why I Use Standalone Instead of Integrated

### The Question

When setting up my NixOS configuration, I had to decide between two approaches for managing my user environment with Home Manager: integrated (as a NixOS module) or standalone (separate from the system configuration). After weighing the options, I went with the standalone approach.

### What's the Difference?

**Integrated Home Manager** runs as part of your NixOS system configuration. You rebuild everything together with one command:
```bash
sudo nixos-rebuild switch --flake .#alucard
```

**Standalone Home Manager** is completely separate from your NixOS system. You rebuild them independently:
```bash
sudo nixos-rebuild switch --flake .#alucard  # System only
home-manager switch --flake .#pixel-peeper@alucard  # User environment only
```

### My Current Setup

I'm using standalone Home Manager with:
- **NixOS system config** (`nixosConfigurations.alucard`) managing kernel, drivers, system services, and boot configuration
- **Home Manager config** (`homeConfigurations."pixel-peeper@alucard"`) managing dotfiles, user packages, Hyprland, terminal setup, and applications
- **Shell aliases** (`nrs` and `hms`) to make rebuilding quick and easy
- **Combined `upgrade` alias** that updates flake, rebuilds both, and cleans up

This separation gives me the flexibility to iterate quickly on my desktop and terminal configuration without touching the system.

### ROI Analysis

#### For My Use Case

**ROI: High**

I'm constantly tweaking my Hyprland setup, Neovim config, terminal settings, and application preferences. With standalone Home Manager:
- Rebuilds take ~30 seconds instead of 5+ minutes
- No sudo needed for most of my daily changes
- I can experiment freely without risking system stability
- Fast iteration means I actually enjoy refining my setup

#### For Set-and-Forget Configs

**ROI: Low to Negative**

If I rarely changed my configuration (like on a stable server or production machine), the integrated approach would be simpler. But that's not how I use my dotfiles - they're constantly evolving.

### Pros of Standalone Home Manager

1. **Blazing Fast User Updates**: Tweaking my Kitty config or Hyprland keybinds rebuilds in seconds, not minutes. I don't have to wait for kernel modules or system services to rebuild.

2. **No Sudo for User Changes**: I can rebuild my entire user environment without root privileges. Safer and faster since I'm not touching system configuration.

3. **Independent Rollbacks**: If I break my Hyprland setup, I can roll back just my user environment without affecting the system. Separate generations for separate concerns.

4. **Better Mental Model**: Clear separation between system stuff (kernel, drivers, services) and user stuff (dotfiles, apps, desktop). Makes it obvious where things belong.

5. **Safer Experimentation**: Want to try a new Neovim plugin or Hyprland layout? Go wild - worst case I break my user environment, not the whole system. Easy to recover.

6. **Future-Proof for Multi-User**: If I ever add another user to my system, they can manage their own Home Manager config independently. Each user gets their own setup.

7. **Cleaner Generation History**: `home-manager generations` shows only user environment changes, not mixed with kernel updates and system service changes. Makes tracking changes easier.

### Cons of Standalone Home Manager

1. **Two Commands Instead of One**: I have to remember to run both `nrs` (NixOS rebuild) and `hms` (Home Manager rebuild) instead of just one command. Though my `upgrade` alias handles this.

2. **Initial Setup Hurdle**: First time requires `nix run home-manager/master -- switch`, which is slightly more complex than integrated. But it's a one-time thing.

3. **Coordination Required**: When I update my flake, I need to rebuild both system and user configs. Miss one and things might be out of sync (though this rarely matters in practice).

4. **Potential Version Drift**: If I rebuild the system but forget to rebuild Home Manager (or vice versa), they could end up on different nixpkgs versions. Haven't hit issues with this yet though.

5. **"Where Does This Go?" Confusion**: Sometimes I pause and think "should this package be in system config or Home Manager?" GUI apps especially can go either way. But I've settled on a rule: if it's user-facing, it goes in Home Manager.

6. **Two Places to Debug**: If something breaks, I need to figure out if it's a system issue or a Home Manager issue. Though this also makes debugging easier since the scope is clearer.

7. **Less Common Pattern**: Most NixOS tutorials show integrated Home Manager, so sometimes I have to translate examples. But the standalone documentation is good enough.

8. **Two Rebuild Failures to Handle**: System build might succeed but Home Manager might fail (or vice versa). Need to be comfortable troubleshooting both independently.

### My Decision

**I'm using standalone Home Manager.**

Here's why this works for me:
- **I'm actively developing my config** - I tweak Hyprland, Neovim, and terminal settings multiple times per week
- **Fast iteration is valuable** - 30-second rebuilds vs 5-minute rebuilds makes me more likely to experiment and improve
- **Clear separation helps** - I know exactly where system stuff lives vs user stuff
- **No sudo for daily work** - Most of my changes are user-level, so not needing root access is convenient
- **My aliases handle complexity** - `nrs`, `hms`, and `upgrade` make the two-command workflow painless

The speed benefit alone is worth it. When I'm fine-tuning my Hyprland layout or testing a new Neovim plugin, waiting 5+ minutes for a full system rebuild kills the flow. With standalone, I make a change, run `hms`, and I'm back to work in 30 seconds.

### Real-World Impact

After a few weeks with this setup, here's what I've noticed:

**What I Love:**
- I experiment more freely because rebuilds are fast
- No sudo password prompts when tweaking my desktop
- When I break something (which happens), it's always isolated to either system or user
- The mental model of "system vs user" makes everything clearer

**What's Annoying:**
- Sometimes I forget to run `hms` after updating flake (but `upgrade` alias solves this)
- Had to learn the `homeConfigurations` syntax instead of just `home-manager.users.pixel-peeper`
- Occasionally wonder if a package should be system-level or user-level (but consistency helps)

**Bottom Line:** The pros far outweigh the cons for my workflow. The speed and flexibility make it worth the minor coordination overhead.

### When I Might Reconsider

I would switch back to integrated Home Manager if:
- I stop actively developing my config and just want set-and-forget simplicity
- I'm setting up a server where I rarely change user config
- I want the absolute simplest possible setup for someone else to maintain
- The coordination overhead starts causing real problems (hasn't happened yet)

For an actively maintained, constantly evolving dotfiles repository like mine, standalone is the clear winner.

---

*Last updated: November 2025*


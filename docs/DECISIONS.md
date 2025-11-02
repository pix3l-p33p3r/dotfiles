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

*Last updated: November 2025*


# Notes & Task Management

CLI-first productivity system built on Taskwarrior 3, Timewarrior, and multiple note-taking apps -- all declaratively managed via Home Manager.

## Task Management

### Packages

Declared in `configs/productivity/task-timewarrior.nix`:

| Package | Purpose |
|---------|---------|
| `taskwarrior3` | Task management CLI |
| `timewarrior` | Time tracking CLI |
| `taskwarrior-tui` | ncurses TUI for Taskwarrior |
| `timew-sync-server` | Self-hosted Timewarrior sync server |

### Configuration

`.taskrc` is managed by Home Manager (`home.file.".taskrc"`):

```
confirmation=no
default.command=next
color=on
report.next.columns=id,project,priority,due.relative,entry.age,description
theme=dark-256
```

`.timewarrior/timewarrior.cfg` ships with defaults.

### Taskwarrior <-> Timewarrior Hook

The official `on-modify.timewarrior` hook is sourced directly from the Timewarrior package:

```nix
home.file.".task/hooks/on-modify.timewarrior" = {
  source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
  executable = true;
};
```

When you `task start` a task, Timewarrior automatically begins tracking time for it. When you `task done` or `task stop`, tracking stops. No custom scripts or `jq` needed -- the upstream hook handles everything.

### Shell Aliases

Defined in `configs/terminal/zsh/config/conf.d/102-aliases.zsh`:

| Alias | Command | Description |
|-------|---------|-------------|
| `t` | `task` | Taskwarrior shorthand |
| `ta` | `task add` | Add a task |
| `tt` | `task +PENDING limit:20` | List pending tasks |
| `td` | `task done` | Mark task done |
| `tdel` | `task delete` | Delete a task |
| `tmod` | `task modify` | Modify a task |
| `tstart` | `timew start` | Start time tracking |
| `tstop` | `timew stop` | Stop time tracking |
| `tw` | `timew` | Timewarrior shorthand |
| `twday` | `timew summary :day` | Today's time summary |
| `tww` | `timew summary :week` | Weekly time summary |
| `twg` | `timew gaps :week` | Weekly time gaps |
| `twsync` | `timew-sync-server serve` | Start sync server |

### Typical Workflow

```bash
ta project:dotfiles "Update README files"    # Add task
t                                            # List tasks (next report)
task 1 start                                 # Start working (Timewarrior auto-tracks)
td 1                                         # Done (auto-stops tracking)
twday                                        # Review today's time
tww                                          # Review weekly summary
```

## Note-Taking Apps

Installed via `configs/desktop/hyprland/core/pkgs.nix`:

| App | Type | Key Feature |
|-----|------|-------------|
| **Obsidian** | GUI (Electron) | Zettelkasten/PKM, local Markdown vault, graph view |
| **Joplin** | GUI (Electron) | Markdown notes, E2E encrypted sync, multi-device |
| **Notesnook** | GUI (Electron) | Zero-knowledge encrypted notes |

All three are installed as regular packages. Obsidian uses a local vault (the Obsidian MCP integration was removed).

## Journaling

| App | Type | Description |
|-----|------|-------------|
| `tui-journal` | TUI | Terminal-based journal entries |
| `lazyjournal` | TUI | Quick journal from terminal |

## Document Tools

Relevant packages from `configs/media/pkgs.nix` and `configs/docs/pkgs.nix`:

| Package | Purpose |
|---------|---------|
| `libreoffice` | Office suite for documents, spreadsheets, presentations |
| `pandoc` | Universal document converter (Markdown, LaTeX, HTML, PDF, DOCX) |
| `texlive.combined.scheme-full` | Full TeX Live for LaTeX |
| `tectonic` | Fast alternative LaTeX engine |
| `mermaid-cli` | Diagram generation from text |
| `graphviz` | Graph/diagram rendering |
| `zathura` | Keyboard-driven PDF viewer (configured in `configs/media/zathura.nix`) |
| `glow` | Markdown viewer in terminal |

## Architecture

```
configs/productivity/
└── task-timewarrior.nix      # Taskwarrior 3 + Timewarrior packages, .taskrc, hook

configs/desktop/hyprland/core/
└── pkgs.nix                  # Obsidian, Joplin, Notesnook, tui-journal, lazyjournal

configs/media/
├── pkgs.nix                  # pandoc, texlive, mermaid-cli, graphviz
└── zathura.nix               # PDF viewer config

configs/docs/
└── pkgs.nix                  # LibreOffice

configs/terminal/zsh/config/conf.d/
└── 102-aliases.zsh           # t, ta, tt, td, tw, twday, tww, twg aliases
```

## Design Decisions

See [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) for rationale on choosing Taskwarrior + Timewarrior + tmux over alternatives.

---

**See Also:**
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) - Tool choices and rationale
- [SHORTCUTS.md](SHORTCUTS.md) - Full alias and keybind reference

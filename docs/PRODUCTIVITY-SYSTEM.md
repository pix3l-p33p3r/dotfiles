# Productivity System

> Personal OS scheduler — built for ADHD/Autism brain, multi-role life (intern + founder + student), CLI-first workflow.
> Rule: **Tasks go in Taskwarrior. Knowledge goes in Obsidian. Nothing else.**

---

## Stack

| Layer | Framework | Tool |
|---|---|---|
| **Capture** | GTD — dump everything fast, no formatting | `ta` (Taskwarrior) · Obsidian `inbox.md` |
| **Classify** | 4D Model — Impact · Effort · Urgency · Alignment | Taskwarrior UDAs |
| **Prioritize** | Eisenhower Matrix → route to quadrant | `task next` sorted by score |
| **Execute** | Eat the Frog + Time Blocking | Taskwarrior start/stop · Google Calendar |
| **Store** | PARA — Projects · Areas · Resources · Archive | Obsidian vault |
| **Reflect** | Weekly Review (Sunday, 30 min max) | Obsidian `weekly/YYYY-WNN.md` |

---

## The Two Rules

```
1. Is it something to DO?     → Taskwarrior
2. Is it something to KNOW?   → Obsidian
```

Everything else is noise.

---

## Full Pipeline

```
┌─────────────────────────────────────────────────────┐
│                  SOMETHING APPEARS                  │
│         (thought / ping / idea / deadline)          │
└─────────────────────┬───────────────────────────────┘
                      │
          ┌───────────▼───────────┐
          │   To DO or to KNOW?   │
          └───────┬───────┬───────┘
                  │       │
               DO │       │ KNOW
                  │       │
     ┌────────────▼─┐   ┌─▼──────────────────┐
     │  task add    │   │  Obsidian inbox.md  │
     │  (terminal   │   │  (mobile or nvim)   │
     │  or phone)   │   └─────────────────────┘
     └────────┬─────┘
              │
     ┌────────▼──────────────────────────┐
     │  Score it (4D) — once per day     │
     │  impact:N effort:N urgency:N      │
     │  alignment:N                      │
     └────────┬──────────────────────────┘
              │
     ┌────────▼──────────────────────────┐
     │  Eisenhower route                 │
     │  Q1 → task start now              │
     │  Q2 → time-block in calendar      │
     │  Q3 → delegate or batch           │
     │  Q4 → task delete                 │
     └────────┬──────────────────────────┘
              │
     ┌────────▼──────────────────────────┐
     │  task start <id>                  │
     │  (Timewarrior auto-tracks)        │
     └────────┬──────────────────────────┘
              │
     ┌────────▼──────────────────────────┐
     │  task done <id>                   │
     │  (tracking stops, logged)         │
     └───────────────────────────────────┘
```

---

## 4D Scoring Model

Every task gets four numbers (1–10):

| Axis | Question |
|---|---|
| **Impact** | How much value does completing this create? |
| **Effort** | How much time + energy does it cost? |
| **Urgency** | How soon does this need action? |
| **Alignment** | Does this serve my long-term goals? |

### Priority Score Formula

```
Priority = (Impact × Alignment × Urgency) / Effort
```

| Result | Meaning | Action |
|---|---|---|
| High Impact + Low Effort | Quick win | Do today |
| High Impact + High Alignment | Deep work | Time-block Q2 |
| High Urgency + Low Alignment | **Trap task** | Delegate or minimize |
| Low Impact + High Effort | Energy drain | Kill it |

### Taskwarrior UDA Setup

Add to `.taskrc` (via Home Manager `task-timewarrior.nix`):

```ini
uda.impact.type=numeric
uda.impact.label=Impact
uda.effort.type=numeric
uda.effort.label=Effort
uda.alignment.type=numeric
uda.alignment.label=Align
```

Add a task with scoring:

```bash
ta "Design Helios Nexus auth flow" project:helios priority:H impact:9 effort:6 urgency:5 alignment:10
```

---

## Eisenhower Matrix

```
                        IMPORTANT
                            │
          Q2 ───────────────┼─────────────── Q1
       Schedule             │             Do First
  (Helios architecture,     │       (internship deadlines,
   42 transfer prep,        │        prod incidents,
   Helios Genesis R&D,      │        1337 evaluations,
   security research)       │        critical bugs)
                            │
NOT URGENT ─────────────────┼───────────────────── URGENT
                            │
          Q4 ───────────────┼─────────────── Q3
         Delete             │            Delegate
   (social scrolling,       │       (non-critical emails,
    over-polishing,         │        minor admin tasks,
    trivial meetings,       │        other people's urgencies,
    low-ROI distractions)   │        routine pings)
                            │
                       NOT IMPORTANT
```

> **Q2 is where real growth lives.**
> It never feels urgent — until it's too late.
> Protect it with time blocks. Every week.

---

## PARA Storage (Obsidian)

```
vault/
├── Projects/          # Active work with deadline
│   ├── helios-nexus/
│   ├── atlas-cloud-internship/
│   └── 1337-curriculum/
├── Areas/             # Ongoing, no end date
│   ├── health/
│   ├── finance/
│   └── career/
├── Resources/         # Reference by topic
│   ├── fhir-standards/
│   ├── bioinformatics/
│   └── devsecops/
├── Archive/           # Inactive / completed
└── inbox.md           # ← everything lands here first
```

**Rule:** Process `inbox.md` once per day (5 min). Move each note to its PARA home or delete it.

---

## Energy-Aware Time Blocks

| Time | Energy | Best Task Type |
|---|---|---|
| 06:00–10:00 | 🔥 Peak | Q2 Deep Work (Helios, research, architecture) |
| 10:00–13:00 | ⚡ High | Q1 Execution (internship deliverables, deadlines) |
| 14:00–16:00 | 🌀 Low | Q3 Admin (emails, reviews, short meetings) |
| 16:00–19:00 | 📖 Medium | Learning, light coding, reading papers |
| 19:00+ | 🌙 Wind down | Capture, plan tomorrow, weekly review |

> Helios thinking should **never** happen at 6 PM after a full Atlas Cloud day.

---

## Daily Routine (15 min total)

```
Morning (5 min):
  task next                    → what is my #1 task today?
  task start <id>              → begin, Timewarrior auto-tracks

Midday (5 min):
  twday                        → how is my time going?
  process any new captures

Evening (5 min):
  td <id>                      → done
  ta any new tasks captured    → add + score
  review inbox.md              → move or delete
```

---

## Weekly Review (Sunday, 30 min max)

```
1. Clear Taskwarrior inbox      → score and route all pending tasks
2. Review tww                   → where did time actually go?
3. Check Q2 blocks              → did deep work happen? reschedule if not
4. Process Obsidian inbox.md    → file into PARA
5. Write weekly/YYYY-WNN.md     → 3 wins, 1 lesson, top 3 next week
6. Check alignment              → is this week moving Helios + career forward?
```

---

## Tool Decisions

| Tool | Status | Role |
|---|---|---|
| **Taskwarrior 3** | ✅ Keep | Execution engine — all tasks live here |
| **Timewarrior** | ✅ Keep | Auto time-tracking via on-modify hook |
| **taskwarrior-tui** | ✅ Keep | Visual dashboard when needed |
| **Obsidian** | ✅ Keep | Knowledge base + PARA + weekly journal |
| **Neovim** | ✅ Keep | Writing in terminal, feeds Obsidian vault |
| **Google Calendar** | ✅ Keep | Time-blocking Q2 deep work slots |
| **Joplin** | ❌ Removed | Redundant with Obsidian |
| **Notesnook** | ❌ Removed | Redundant with Obsidian |
| **Google Keep** | ❌ Removed | Redundant capture point |
| **Google Tasks** | ❌ Removed | Redundant with Taskwarrior |

---

## Phone Workflow

| App | Role |
|---|---|
| **Obsidian mobile** | Only capture point for knowledge / ideas |
| **Google Calendar** | View time blocks, not create tasks |
| **Notion** | Helios docs read-only (heavy reference) |

> On mobile: **capture only**. Score and route at the laptop, once per day.

---

## Anti-Patterns (Don't Do These)

- ❌ Building the system instead of using it
- ❌ Spending > 10 min/day on system maintenance
- ❌ Opening Joplin, Notesnook, or Google Keep
- ❌ Creating a new Notion database for tasks
- ❌ Letting Q3 (trap tasks) eat Q2 time blocks
- ❌ Scoring tasks in real-time (batch once daily)
- ❌ Optimizing the system before using it for 30 days

---

## Shell Aliases Reference

| Alias | Command | Use |
|---|---|---|
| `ta` | `task add` | Capture a task |
| `t` | `task next` | What do I work on now? |
| `tstart` | `task <id> start` | Begin task (auto-tracks time) |
| `td` | `task done` | Mark done (stops tracking) |
| `twday` | `timew summary :day` | Today's time |
| `tww` | `timew summary :week` | Week's time |

---

## See Also

- [NOTES-AND-TASKS.md](NOTES-AND-TASKS.md) — Tool setup and configuration
- [DECISIONS-TOOLING.md](DECISIONS-TOOLING.md) — Why Taskwarrior + Timewarrior
- [SHORTCUTS.md](SHORTCUTS.md) — Full alias and keybind reference

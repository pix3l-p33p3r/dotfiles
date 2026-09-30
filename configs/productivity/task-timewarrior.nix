{ pkgs, ... }:
let
  taskAccomplish = pkgs.writeShellApplication {
    name = "task-accomplish";
    runtimeInputs = [ pkgs.taskwarrior3 pkgs.timewarrior pkgs.coreutils pkgs.gnused ];
    text = ''
      set -eu

      usage() {
        echo "Usage: task-accomplish \"Description\" [area:nixos kind:feat impact:N ...] [-m minutes]" >&2
        exit 1
      }

      MINUTES=""
      ARGS=()
      while [[ ''$# -gt 0 ]]; do
        case "''$1" in
          -m)
            [[ ''$# -ge 2 ]] || usage
            MINUTES="''$2"
            shift 2
            ;;
          -h|--help)
            usage
            ;;
          *)
            ARGS+=( "''$1" )
            shift
            ;;
        esac
      done

      [[ ''${#ARGS[@]} -ge 1 ]] || usage

      DESCRIPTION="''${ARGS[0]}"
      EXTRA=( "''${ARGS[@]:1}" )

      task add \
        project:dotfiles \
        source:agent \
        status:completed \
        end:now \
        entry:now \
        "description:''${DESCRIPTION}" \
        "''${EXTRA[@]}"

      if [[ -n "''${MINUTES}" ]]; then
        AREA=""
        KIND=""
        for arg in "''${EXTRA[@]}"; do
          case "''$arg" in
            area:*)
              AREA="''${arg#area:}"
              ;;
            kind:*)
              KIND="''${arg#kind:}"
              ;;
          esac
        done

        END=$(date +%Y%m%dT%H%M%S)
        START_EPOCH=$(( $(date +%s) - MINUTES * 60 ))
        START=$(date -d "@''${START_EPOCH}" +%Y%m%dT%H%M%S)

        TW_TAGS=( dotfiles )
        [[ -n "''${AREA}" ]] && TW_TAGS+=( "area.''${AREA}" )
        [[ -n "''${KIND}" ]] && TW_TAGS+=( "kind.''${KIND}" )

        timew track :adjust "''${START}" - "''${END}" "''${TW_TAGS[@]}"
      fi
    '';
  };

  taskMetrics = pkgs.writeShellApplication {
    name = "task-metrics";
    runtimeInputs = [ pkgs.taskwarrior3 pkgs.timewarrior pkgs.coreutils pkgs.gnugrep pkgs.jq ];
    text = ''
      set -eu
      TIME_ARGS=( ":month" )
      TASK_FILTER=()
      if [[ ''$# -ge 3 && "''${2}" == "-" ]]; then
        TIME_ARGS=( "''$1" "-" "''$3" )
        TASK_FILTER=( "''$1" "-" "''$3" )
        shift 3
      elif [[ ''$# -ge 1 ]]; then
        TIME_ARGS=( "''$1" )
        TASK_FILTER=( "''$1" )
        shift
      fi
      if [[ ''$# -gt 0 ]]; then
        TASK_FILTER+=( "$@" )
      fi
      INTERVAL_LABEL="''${TIME_ARGS[*]}"

      timew_hours() {
        timew summary "''${TIME_ARGS[@]}" "''$1" 2>/dev/null \
          | awk '
              NF && $NF ~ /^[0-9]+:[0-9]+:[0-9]+$/ { total = $NF }
              END {
                if (total == "") { printf "0.0h"; exit }
                split(total, t, ":")
                printf "%.1fh", (t[1] * 3600 + t[2] * 60 + t[3]) / 3600
              }'
      }

      echo "=== Taskwarrior: completed by area ==="
      task export status:completed "''${TASK_FILTER[@]}" 2>/dev/null \
        | jq -r '
            group_by(.area // "unset")
            | sort_by(.[0].area // "zzz")
            | .[]
            | "  \(.[0].area // "unset" | . + " " * (14 - length))  \(length) tasks"'

      echo
      echo "=== Taskwarrior: completed by kind ==="
      task export status:completed "''${TASK_FILTER[@]}" 2>/dev/null \
        | jq -r '
            group_by(.kind // "unset")
            | sort_by(.[0].kind // "zzz")
            | .[]
            | "  \(.[0].kind // "unset" | . + " " * (14 - length))  \(length) tasks"'

      echo
      echo "=== Taskwarrior: 4D averages (completed) ==="
      task export status:completed "''${TASK_FILTER[@]}" 2>/dev/null \
        | jq -r '
            [.[] | select(.impact != null)]
            | if length == 0 then "  (no scored completed tasks in filter)"
              else
                (length) as $n
                | ((map(.impact)|add)/$n) as $imp
                | ((map(.effort)|add)/$n) as $eff
                | ((map(.u4d)|add)/$n) as $urg
                | ((map(.alignment)|add)/$n) as $ali
                | "  tasks=\($n)  avg impact=\($imp)  effort=\($eff)  u4d=\($urg)  alignment=\($ali)"
              end'

      echo
      echo "=== Timewarrior: hours by area tag ==="
      for area in nixos desktop security network editors productivity; do
        total=$(timew_hours "area.$area")
        printf "  area.%-12s %s\n" "$area" "$total"
      done

      echo
      echo "=== Timewarrior: hours by kind tag ==="
      for kind in maintenance feat fix chore docs; do
        total=$(timew_hours "kind.$kind")
        printf "  kind.%-12s %s\n" "$kind" "$total"
      done

      echo
      echo "=== Timewarrior: total ($INTERVAL_LABEL) ==="
      timew summary "''${TIME_ARGS[@]}" dotfiles 2>/dev/null | tail -3
    '';
  };
in
{
  home.packages = with pkgs; [
    taskwarrior3
    timewarrior
    taskwarrior-tui
    timew-sync-server
    taskMetrics
    taskAccomplish
  ];

  home.file = {
    ".taskrc".text = ''
      # Taskwarrior — capture, 4D scoring, multi-axis reports
      confirmation=no
      default.command=next
      color=on
      news.read=all
      theme=dark-256
      rule.precedence.color=due,blocked,active,scheduled,keyword,project,tag,uda,priority

      # ── 4D + taxonomy (see docs/PRODUCTIVITY-SYSTEM.md) ──
      uda.impact.type=numeric
      uda.impact.label=Impact
      uda.effort.type=numeric
      uda.effort.label=Effort
      uda.u4d.type=numeric
      uda.u4d.label=Urg4D
      uda.alignment.type=numeric
      uda.alignment.label=Align

      uda.area.type=string
      uda.area.label=Area
      uda.kind.type=string
      uda.kind.label=Kind
      uda.source.type=string
      uda.source.label=Source

      # ── Default list ──
      report.next.description=Next actionable tasks
      report.next.columns=id,project,area,kind,impact,u4d,priority,due.relative,description
      report.next.labels=ID,Project,Area,Kind,Imp,Urg4D,Pri,Due,Description
      report.next.sort=u4d-,impact-,due+
      report.next.filter=status:pending

      # ── Multi-metric views ──
      report.byarea.description=Tasks grouped by life area
      report.byarea.columns=id,project,area,kind,impact,effort,u4d,alignment,end,description
      report.byarea.labels=ID,Project,Area,Kind,Imp,Eff,Urg4D,Align,Done,Description
      report.byarea.sort=area+,impact-,end-
      report.byarea.filter=status:completed

      report.bykind.description=Tasks grouped by work type
      report.bykind.columns=id,area,kind,impact,u4d,alignment,end,description
      report.bykind.labels=ID,Area,Kind,Imp,Urg4D,Align,Done,Description
      report.bykind.sort=kind+,impact-,end-
      report.bykind.filter=status:completed

      report.matrix.description=4D scoreboard (pending)
      report.matrix.columns=id,area,kind,impact,effort,u4d,alignment,description
      report.matrix.labels=ID,Area,Kind,Imp,Eff,Urg4D,Align,Description
      report.matrix.sort=u4d-,impact-
      report.matrix.filter=status:pending

      report.worklog.description=Completed work log (newest first)
      report.worklog.columns=end,area,kind,source,impact,effort,project,description
      report.worklog.labels=Done,Area,Kind,Source,Imp,Eff,Project,Description
      report.worklog.sort=end-
      report.worklog.filter=status:completed
    '';

    ".timewarrior/timewarrior.cfg".text = ''
      # Tag intervals with area.* kind.* source.* (see task-metrics)
    '';

    ".task/hooks/on-modify.timewarrior" = {
      source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
      executable = true;
    };
  };

  programs.zsh.shellAliases = {
    t = "task";
    ta = "task add";
    tt = "task +PENDING limit:20";
    td = "task done";
    tdel = "task delete";
    tmod = "task modify";

    tarea = "task byarea";
    tkind = "task bykind";
    tmatrix = "task matrix";
    tlog = "task worklog";
    tmetrics = "task-metrics";
    tacc = "task-accomplish";

    tstart = "timew start";
    tstop = "timew stop";
    tw = "timew";
    twday = "timew summary :day";
    tww = "timew summary :week";
    twg = "timew gaps :week";
    twsync = "timew-sync-server serve";
    twarea = "timew summary :month area.";
    twkind = "timew summary :month kind.";
  };
}

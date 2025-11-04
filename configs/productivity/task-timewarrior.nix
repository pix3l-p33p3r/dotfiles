{ pkgs, ... }:
{
  # CLI tools for tasks and time tracking
  home.packages = with pkgs; [
    taskwarrior2
    timewarrior
    taskwarrior-tui
    timew-sync-server
    jq  # Required for parsing task JSON in hook
  ];

  # Taskwarrior + Timewarrior integration hook and configs
  home.file = {
    ".taskrc" = {
      text = ''
        # Taskwarrior configuration
        confirmation=no
        default.command=next
        color=on
        news.read=all
        report.next.columns=id,project,priority,due.relative,age,description
        report.next.labels=ID,Project,Pri,Due,Age,Description
        rule.precedence.color=due,blocked,active,scheduled,keyword,project,tag,uda,priority
        theme=dark-256
      '';
    };

    ".timewarrior/timewarrior.cfg".text = ''
      # Timewarrior configuration (defaults are fine)
    '';

    ".task/hooks/on-modify.timewarrior" = {
      text = ''
        #!/usr/bin/env bash
        # Timewarrior hook for Taskwarrior
        # Integrates time tracking with task management
        
        # Exit if timew is not available
        command -v timew >/dev/null 2>&1 || exit 0
        command -v task >/dev/null 2>&1 || exit 0
        
        # Taskwarrior passes modified task JSON as first argument
        TASK_JSON="$1"
        
        # Extract task UUID and query task status
        TASK_UUID=$(echo "$TASK_JSON" | ${pkgs.jq}/bin/jq -r '.uuid // empty')
        if [ -z "$TASK_UUID" ]; then
            exit 0
        fi
        
        # Query task status and description
        STATUS=$(task "$TASK_UUID" export 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].status // empty')
        DESCRIPTION=$(task "$TASK_UUID" export 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].description // empty')
        
        # Start tracking when task becomes active
        if [ "$STATUS" = "pending" ] || [ "$STATUS" = "active" ]; then
            # Check if already tracking
            if ! timew get dom.active >/dev/null 2>&1; then
                timew start "$DESCRIPTION" >/dev/null 2>&1
            fi
        fi
        
        # Stop tracking when task is completed or deleted
        if [ "$STATUS" = "completed" ] || [ "$STATUS" = "deleted" ]; then
            timew stop >/dev/null 2>&1
        fi
      '';
      executable = true;
    };
  };
}



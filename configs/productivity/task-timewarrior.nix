{ pkgs, ... }:
{
  # CLI tools for tasks and time tracking
  home.packages = with pkgs; [
    taskwarrior
    timewarrior
    taskwarrior-tui
    timew-sync-server
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
      source = pkgs.timewarrior + "/share/doc/timew/hooks/on-modify.timewarrior";
      executable = true;
    };
  };
}



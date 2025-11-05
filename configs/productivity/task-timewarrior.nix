{ pkgs, ... }:
{
  # CLI tools for tasks and time tracking
  home.packages = with pkgs; [
    taskwarrior3
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
      # Use the official Timewarrior hook shipped with the package
      source = "${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior";
      executable = true;
    };
  };
}



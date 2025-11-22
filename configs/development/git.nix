{ config, pkgs, ... }:
{
  # Git commit message template
  home.file.".config/git/template" = {
    enable = true;
    force = true;
    text = ''
      # feat(): 
      # fix():
      # build():
      # ci():
      # test():
      # docs():
      # refactor():
      # perf():
      # style():
      # chore():
      # revert():

      # Body

      # Footer
    '';
  };

  # Global gitignore patterns
  home.file.".config/git/ignore" = {
    enable = true;
    force = true;
    text = ''
      *.com
      *.class
      *.dll
      *.exe
      *.o
      *.so
      *.pyc
      *.pyo

      *.7z
      *.dmg
      *.gz
      *.iso
      *.jar
      *.rar
      *.tar
      *.zip
      *.msi

      # Logs and databases
      *.log
      logs/
      *.sql
      *.sqlite

      # Vim
      *.swp
      *.swo
      *.un~

      # OS generated files
      .DS_Store
      .DS_Store?
      ._*
      .Spotlight-V100
      .Trashes
      ehthumbs.db
      Thumbs.db
      desktop.ini

      # Temp files
      *.bak
      *.swp
      *.swo
      *~
      *#

      # Secrets
      .env
      .env.*.local
      .env.local
      *.pem
      *.key
      *.crt
      *.p12
      *.jks
      *.keystore

      # IDE files
      .vscode
      .idea
      .iml
      *.sublime-workspace

      # Misc
      **/node_modules/
      **/dist/
      **/build/
      *.bak
      *.tmp
      *.temp
      *.old
      .docker/
      *.orig
      __pycache__/
      *.py[cod]
      *.pyo
      .cache/
      dist/
    '';
  };

  programs.git = {
    enable = true;

    # Conditional config for 1337 School (vogsphere)
    includes = [
      {
        condition = "gitdir:~/Code/42/";
        contents = {
          user = {
            email = "pixel-peeper@student.1337.ma";
            name = "pixel-peeper";
          };
        };
      }
    ];

    settings = {
      user = {
        email = "pix3l-p33p3r@proton.me";
        name = "pixel-peeper";
      };
      core.excludesfile = "~/.config/git/ignore";
      core.editor = "nvim";
      core.pager = "delta";
      branch.sort = "-committerdate";
      color.ui = "auto";
      init.defaultBranch = "main";
      commit.template = "~/.config/git/template";
      push.autoSetupRemote = true;
      commit.gpgsign = true;
      user.signingKey = "6334D8CA23365A72";
      # Git automatically respects the remote URL:
      # - If cloned with HTTPS (https://github.com/user/repo), uses HTTPS for push/pull
      # - If cloned with SSH (git@github.com:user/repo), uses SSH for push/pull
      # No URL rewriting needed - git uses the remote URL as configured
      
      alias = {
        # add
        a = "add";
        aa = "add .";

        # commit
        c = "commit";
        cm = "commit -m";
        cam = "commit -am";

        # status
        s = "status -s";

        # push
        p = "push";
        pf = "push --force-with-lease";

        # pull
        pl = "pull";

        # clone
        cl = "clone";
        cls = "clone --depth=1"; # shallow clone

        # diff
        d = "diff";
        ds = "diff --staged";

        # log
        l = "log";
        lo = ''log --pretty=format:"%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]" --decorate --date=short'';

        # stash
        staash = "stash --all";

        # branch
        b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
      };
    };
  };
}


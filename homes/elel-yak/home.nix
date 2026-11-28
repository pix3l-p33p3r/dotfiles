{
  config,
  pkgs,
  lib,
  antigravity,
  codex-desktop-linux,
  nixGLIntel,
  ...
}:
{
  imports = [
    # Shared base modules from pix3l-p33p3r/dotfiles
    ../../configs/terminal/tmux.nix
    ../../configs/terminal/yazi.nix
    ../../configs/development/git.nix
    ../../configs/media/ani-cli.nix

    # 1337 cluster deviant modules
    ./modules/packages.nix
    ./modules/shell.nix # kitty.conf stays a real file; do not enable programs.kitty
    ./modules/desktop.nix
    ./modules/theming.nix
    ./modules/antigravity.nix
    ./modules/codex.nix
  ];

  # Cluster overrides over shared base modules
  home.packages = [ nixGLIntel ];
  programs.git.settings.commit.gpgsign = lib.mkForce false;
  programs.atuin.enable = true;

  # Catppuccin Mocha Lavender for portable CLI/TUI apps (matches homes/pixel-peeper/catppuccin.nix).
  # Keep catppuccin.kitty.enable = false — kitty.conf stays a real file outside nix-user-chroot.
  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "lavender";
    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fzf.enable = true;
    tmux.enable = true;
    atuin.enable = true;
    lazygit.enable = true;
  };

  home.username = "elel-yak";
  home.homeDirectory = "/home/elel-yak";
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  # Goinfre-friendly XDG (matches cluster ~/.zshenv)
  xdg.enable = true;
  xdg.cacheHome = "/goinfre/elel-yak/cache";
  xdg.dataHome = "/goinfre/elel-yak/xdg-data";
  xdg.stateHome = "/goinfre/elel-yak/xdg-state";

  home.sessionVariables = {
    GOINFRE = "/goinfre/elel-yak";
    # Lean via devenv; toolchains on hynix — `toolchain-gc lean` frees them.
    ELAN_HOME = "/media/elel-yak/hynix256/toolchains/elan";
    EDITOR = "nvim";
    VISUAL = "nvim";
    # ocl-icd + Khronos loader: rusticl (Mesa) + intel-neo from the HM profile
    OCL_ICD_VENDORS = "${config.home.profileDirectory}/etc/OpenCL/vendors";
    OPENCL_VENDOR_PATH = "${config.home.profileDirectory}/etc/OpenCL/vendors";
    # Enable rusticl on AMD (radeonsi) + Intel (iris). AMD needs kernel DRM
    # new enough for the nixpkgs mesa (see README / RT notes on 5.15).
    RUSTICL_ENABLE = "radeonsi,iris";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.nix-profile/bin"
  ];

  # Don't clobber existing zap-managed interactive zsh; only ensure profile PATH.
  programs.bash.enable = true;

  # Antigravity IDE (and other Electron FHS apps) replace /usr inside bwrap,
  # so host /usr/share/fonts vanish. Nix fonts under the profile stay visible.
  fonts.fontconfig.enable = true;
  # Home Manager's default cachedir is the profile path inside /nix/store.
  # nix-user-chroot leaves that store user-writable, so fc-cache drops mode-0644
  # files there and `nix store optimise` warns on every one. Keep the cache on goinfre.
  fonts.fontconfig.configFile.fonts.settings.cachedir = lib.mkForce "${config.xdg.cacheHome}/fontconfig";
}

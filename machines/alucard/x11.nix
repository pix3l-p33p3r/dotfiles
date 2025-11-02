{ config, pkgs, ... }:

{
  # ───── X11 (required for some compatibility) ─────
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}


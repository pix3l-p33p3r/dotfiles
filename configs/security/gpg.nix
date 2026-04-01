{ config, pkgs, lib, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      keyserver = "keys.openpgp.org";
      auto-key-retrieve = true;
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 28800;
    maxCacheTtl = 86400;
  };

  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GPG_SECRET_PATH="${toString (config.sops.secrets."gpg/private_key" or { path = ""; }).path}"
    if [ -n "$GPG_SECRET_PATH" ] && [ -f "$GPG_SECRET_PATH" ]; then
      $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_SECRET_PATH" 2>/dev/null || true
    fi
  '';
}

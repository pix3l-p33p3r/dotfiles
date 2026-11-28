{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  files = lib.mapAttrsToList (dest: f: f // { inherit dest; }) config.home.hostFiles;
  manifest = pkgs.writeText "hm-host-files" (lib.concatMapStrings (f: "${f.dest}\n") files);
in
{
  options.home.hostFiles = mkOption {
    default = { };
    description = ''
      Files read outside nix-user-chroot (GNOME, host systemd, host shells),
      where /nix does not exist and home.file symlinks dangle. Each is copied
      from its store path on activation, so it changes with the generation and
      rolls back with it. Paths are relative to $HOME. Entries removed from
      this set are deleted on the next activation.
    '';
    type = types.attrsOf (
      types.submodule {
        options = {
          source = mkOption { type = types.path; };
          executable = mkOption {
            type = types.bool;
            default = false;
          };
        };
      }
    );
  };

  config.home.activation.hostFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    hostFilesState="$HOME/.local/state/hm-host-files"
    if [[ -f "$hostFilesState" ]]; then
      while IFS= read -r rel; do
        grep -qxF -- "$rel" ${manifest} || run rm -f "$HOME/$rel"
      done < "$hostFilesState"
    fi
    ${lib.concatMapStrings (
      f:
      let
        dest = ''"$HOME/"${lib.escapeShellArg f.dest}'';
      in
      ''
        run install -D -m ${if f.executable then "755" else "644"} "${f.source}" ${dest}.hm-new
        run mv -f ${dest}.hm-new ${dest}
      ''
    ) files}
    run install -D -m 644 ${manifest} "$hostFilesState"
  '';
}

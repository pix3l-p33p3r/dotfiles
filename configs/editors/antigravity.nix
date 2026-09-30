# Google Antigravity suite via community flake (not yet in nixpkgs).
# https://github.com/Hy4ri/antigravity-flake
#
# Packages:
#   antigravity      ? Hub / agent command center (`antigravity`)
#   antigravity-ide  ? IDE via FHS wrap (`antigravity-ide`) ? needed on NixOS
#   agy              ? CLI (`agy`)
#   agy-python       ? Python 3 with Antigravity SDK on PYTHONPATH
#
# Electron on NixOS cannot use chrome-sandbox (no setuid in the store), so we
# re-wrap Hub/IDE with --no-sandbox like configs/editors/cursor.nix.
{ pkgs, inputs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  agyPkgs = inputs.antigravity.packages.${system};

  electronFlags = [
    "--no-sandbox"
    "--ozone-platform-hint=auto"
  ];

  wrapElectronBin =
    {
      name,
      package,
      bin ? name,
    }:
    pkgs.symlinkJoin {
      inherit name;
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/${bin}" \
          ${lib.concatMapStringsSep " " (f: "--add-flags ${lib.escapeShellArg f}") electronFlags}
      '';
      meta = package.meta // {
        mainProgram = bin;
      };
    };

  antigravity = wrapElectronBin {
    name = "antigravity";
    package = agyPkgs.antigravity;
  };

  antigravity-ide = wrapElectronBin {
    name = "antigravity-ide";
    package = agyPkgs.antigravity-fhs;
    bin = "antigravity-ide";
  };

  # Dedicated interpreter so we don't collide with pkgs.python3 from
  # configs/development/pkgs.nix (two `python3` bins in home.packages).
  pythonWithSdk = pkgs.python3.withPackages (_: [ agyPkgs.antigravity-sdk ]);
  agy-python = pkgs.runCommand "agy-python" {
    meta = {
      description = "Python 3 with Google Antigravity SDK";
      mainProgram = "agy-python";
    };
  } ''
    mkdir -p $out/bin
    ln -s ${lib.getExe' pythonWithSdk "python3"} $out/bin/agy-python
  '';
in
{
  home.packages = [
    agyPkgs.antigravity-cli
    antigravity
    antigravity-ide
    agyPkgs.antigravity-sdk
    agy-python
  ];
}

{ pkgs, lib, antigravity, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  agy = antigravity.packages.${system};
  flags = [
    "--no-sandbox"
    "--ozone-platform-hint=auto"
  ];
  wrap =
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
          ${lib.concatMapStringsSep " " (f: "--add-flags ${lib.escapeShellArg f}") flags}
      '';
    };
in
{
  home.packages = [
    agy.antigravity-cli
    (wrap {
      name = "antigravity";
      package = agy.antigravity;
    })
    (wrap {
      name = "antigravity-ide";
      package = agy.antigravity-fhs;
      bin = "antigravity-ide";
    })
  ];
}

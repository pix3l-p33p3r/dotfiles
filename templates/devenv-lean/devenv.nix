# Lean via nixpkgs elan; toolchains live on hynix (not goinfre).
# lake/lean-toolchain still pins the exact Lean (e.g. v4.36.0).
# Copy into a Lake project, then:
#   devenv shell          # or: direnv allow
# When done:
#   toolchain-gc lean
{ pkgs, ... }:
let
  elanHome = "/media/elel-yak/hynix256/toolchains/elan";
in
{
  packages = with pkgs; [
    elan
    git
    curl
    pkg-config
  ];

  env.ELAN_HOME = elanHome;

  enterShell = ''
    mkdir -p "$ELAN_HOME"
    export PATH="$ELAN_HOME/bin:$PATH"
    # Drop stale goinfre elan from PATH if a login shell injected it
    export PATH="$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '/goinfre/.*/elan/bin' | paste -sd:)"
    echo "📐 elan → $ELAN_HOME (hynix)"
    if command -v lean >/dev/null 2>&1; then
      lean --version 2>/dev/null || true
    else
      echo "   first build will fetch lean-toolchain into hynix"
    fi
    echo "   free lean disk: toolchain-gc lean"
  '';
}

{
  lib,
  stdenvNoCC,
  fetchurl,
}:

# Official musl *package* (not the bare binary). Includes codex-resources/,
# codex-path/, and helpers. The bare `codex-*-musl.tar.gz` binary exits with
# "this CLI has no complete local package".
stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.172.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-Y+OwAGXtf2IWbQUi4X9mPLhmox2A0D5jNlSC7TSh2ZE=";
  };

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  # Musl static binaries + bundled libs — leave them alone.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    # Preserve the package layout the binary expects next to bin/codex.
    cp -a bin codex-package.json codex-path codex-resources "$out/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI (official musl package)";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "codex";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}

{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "codex";
  version = "0.172.0";

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-ojQqj39o8Ii+MGIMz+nLhBYsk6a1YXeFWWHNo+1r45I=";
  };

  # Official musl static binary — no patchelf, no system glibc.
  dontUnpack = false;
  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 codex-x86_64-unknown-linux-musl "$out/bin/codex"
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI (official musl binary)";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "codex";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}

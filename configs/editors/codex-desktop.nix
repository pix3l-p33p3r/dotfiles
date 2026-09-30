# ChatGPT / Codex desktop (Linux) via community flake wrapping OpenAI's
# official .deb. https://github.com/ilysenko/codex-desktop-linux
#
# The HM module is imported from flake.nix; this file only enables it.
# Binary: codex-desktop. Desktop entry: ChatGPT Community.
{ ... }:
{
  programs.codexDesktopLinux = {
    enable = true;
    # Optional Linux-only features (empty = stock upstream runtime):
    # linuxFeatures = [ "read-aloud" "ui-tweaks" "computer-use-linux" ];
  };
}

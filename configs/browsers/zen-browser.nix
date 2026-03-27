# Zen Browser (twilight) from community flake; Firefox remains the default browser elsewhere.
# HM module: flake `inputs.zen-browser.homeModules.twilight`
# https://github.com/0xc000022070/zen-browser-flake
{ ... }:
{
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      extensions.packages = [];
    };
  };
}

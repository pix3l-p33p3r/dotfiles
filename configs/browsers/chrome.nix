{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;

    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--ignore-gpu-blocklist"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,WaylandWindowDecorations"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--use-angle=vulkan"
      "--enable-wayland-ime=true"
    ];

    dictionaries = with pkgs.hunspellDictsChromium; [
      en_US
      fr_FR
    ];

    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock
    ];
  };
}

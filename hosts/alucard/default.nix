{ ... }:
{
  imports = [
    ../../disko/alucard.nix
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/nix.nix
    ../../modules/users.nix
    ../../modules/audio.nix
    ../../modules/desktop.nix
    ../../modules/home.nix
    ../../modules/secrets.nix
  ];

  networking.hostName = "alucard";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Africa/Casablanca";
  i18n.defaultLocale = "en_US.UTF-8";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 40;
  boot.tmp.useTmpfs = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  services.openssh.enable = false;
  services.fwupd.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
  '';

  documentation.nixos.enable = false;
  documentation.man.generateCaches = false;

  system.stateVersion = "25.05";
}

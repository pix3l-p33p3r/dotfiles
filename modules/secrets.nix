# Elliot owns key rotation. Do not enable sops until the new age recipient
# is in secrets/.sops.yaml and the identity lives off-git.
{ ... }:
{
  # sops.defaultSopsFile = ../secrets/hosts/alucard.yaml;
  # sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}

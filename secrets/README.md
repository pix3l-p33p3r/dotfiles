# secrets

Elliot owns this.

- New age identity off-git (`/var/lib/sops-nix/key.txt` or `~/.config/sops/age/keys.txt`)
- Public recipient in `.sops.yaml`
- Encrypted files under `hosts/` and `users/`
- SSH + GPG rotation happens here, private material never lands in the store

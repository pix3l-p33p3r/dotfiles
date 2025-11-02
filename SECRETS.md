# SOPS + Age Secrets Management Setup

## ✅ Setup Complete

Your dotfiles repository now includes SOPS (Secrets Operations) integrated with Age encryption for managing secrets in your NixOS configuration.

## 📁 Structure

```
dotfiles/
├── flake.nix                              # Added sops-nix input & module
├── .gitignore                             # Protected age keys & secrets
├── secrets/                               # Encrypted secrets
│   ├── .sops.yaml                         # SOPS configuration
│   ├── .gitkeep                           # Keeps directory in git
│   ├── README.md                          # Detailed usage guide
│   ├── hosts/
│   │   └── alucard.yaml              # HOST secrets (encrypted)
│   └── users/
│       └── pixel-peeper.yaml              # USER secrets (encrypted)
└── machines/alucard/
    ├── default.nix                        # Imports secrets.nix
    └── secrets.nix                        # SOPS configuration
```

## 🔑 Key Files

### Age Key
- **Location**: `~/.config/sops/age/keys.txt`
- **Public Key**: `age1zln4nlxttpqehayq4wmve2fcvl80zs2mt0xyh5c7ur56hvztdvdqsnv362`
- **NEVER commit this file to git**

### Configuration
- `secrets/.sops.yaml` - SOPS rules for encryption
- `machines/alucard/secrets.nix` - NixOS SOPS integration

## 🚀 Quick Start

### Edit a Secret

```bash
# Edit host secrets (auto-decrypts/encrypts)
sops secrets/hosts/alucard.yaml

# Edit user secrets
sops secrets/users/pixel-peeper.yaml
```

### Add Your First Real Secret

1. **Edit the secret file**:
   ```bash
   sops secrets/hosts/alucard.yaml
   ```

2. **Replace placeholder**:
   ```yaml
   github_token: "ghp_your_real_token_here"
   ssh_host_key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...
   ```

3. **Save** - SOPS auto-encrypts

4. **Use in NixOS** (`machines/alucard/secrets.nix`):
   ```nix
   sops.secrets."github_token" = {
     owner = config.users.users.pixel-peeper.name;
     mode = "0400";
   };
   
   sops.secrets."ssh_host_key" = {
     owner = "root";
     group = "systemd-network";
     mode = "0400";
   };
   ```

5. **Reference in config**:
   ```nix
   # In system.nix or another module
   environment.variables.GITHUB_TOKEN = config.sops.secrets."github_token".path;
   ```

### Rebuild with Secrets

```bash
# Your next rebuild will automatically decrypt secrets
sudo nixos-rebuild switch --flake .#alucard
```

Secrets are decrypted to `/run/secrets/` at boot/rebuild time.

## 🔒 Security Status

✅ **Installed**: `age`, `sops`, `sops-nix`
✅ **Configured**: Flake input, module, age key
✅ **Encrypted**: All example secret files
✅ **Protected**: Age keys in `.gitignore`

## 📚 Documentation

- **Detailed Guide**: [secrets/README.md](secrets/README.md)
- **SOPS Docs**: https://github.com/getsops/sops
- **sops-nix**: https://github.com/Mic92/sops-nix

## ⚙️ What Changed

1. **flake.nix**: Added `sops-nix` input and module
2. **machines/alucard/default.nix**: Imports `secrets.nix`
3. **machines/alucard/secrets.nix**: NEW - SOPS configuration
4. **secrets/**: NEW - Directory for encrypted secrets
5. **.gitignore**: Protects age keys and unencrypted files

## 🎯 Next Steps

1. **Backup your age key**:
   ```bash
   cp ~/.config/sops/age/keys.txt ~/backups/
   ```

2. **Add real secrets**:
   - SSH keys, API tokens, database passwords, etc.
   - Use `sops secrets/hosts/alucard.yaml` to edit

3. **Commit encrypted files** (after adding real secrets):
   ```bash
   git add secrets/ machines/alucard/secrets.nix
   git commit -m "Add SOPS secrets management"
   ```

4. **Rebuild** to test decryption:
   ```bash
   sudo nixos-rebuild switch --flake .#alucard
   ```

## ⚠️ Important Notes

- **Age key is in `.gitignore`** - Never commit `~/.config/sops/age/keys.txt`
- **Encrypted files are safe to commit** - They're encrypted with your age key
- **Lose the key = lose the secrets** - Keep backups offline
- **Decryption happens at build time** - No manual steps needed

## 🔍 Verify Setup

```bash
# Check age key exists
ls -la ~/.config/sops/age/keys.txt

# Decrypt a test file
sops -d secrets/hosts/alucard.yaml

# Check flake has sops-nix
nix flake show | grep sops-nix
```

## 🆘 Troubleshooting

**"No decryption key available"**
→ Check `~/.config/sops/age/keys.txt` exists

**"Failed to decrypt with age"**
→ Verify public key in `secrets/.sops.yaml` matches your key

**"Permission denied" at rebuild**
→ Check owner/mode in `secrets.nix` match your config

See [secrets/README.md](secrets/README.md) for more troubleshooting.

---

Your secrets are now version-controlled, encrypted, and automatically integrated into your NixOS system! 🎉


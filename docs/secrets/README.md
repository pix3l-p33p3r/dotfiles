# Secrets Management with SOPS + Age

This directory contains encrypted secrets managed with [SOPS](https://github.com/getsops/sops) using the [Age](https://github.com/FiloSottile/age) encryption tool.

## Overview

- **SOPS**: Secrets Operations - YAML/JSON file encryption with key management
- **Age**: Modern, simple, secure encryption tool
- **sops-nix**: NixOS integration for automatic secret decryption during builds

## Directory Structure

```
secrets/
├── .sops.yaml          # SOPS configuration
├── hosts/              # Host-level secrets (NixOS)
│   └── alucard.yaml
└── users/              # User-level secrets (Home Manager)
    └── pixel-peeper.yaml
```

## Usage

### Encrypt a Secret File

```bash
# Encrypt in-place
sops -e -i secrets/hosts/alucard.yaml

# Or create encrypted version
sops -e secrets/hosts/alucard.yaml > secrets/hosts/alucard.yaml.enc
```

### Decrypt and Edit

```bash
# Edit encrypted file (automatically decrypts/encrypts)
sops secrets/hosts/alucard.yaml

# Just decrypt to stdout
sops -d secrets/hosts/alucard.yaml
```

### In NixOS Configuration

```nix
# machines/alucard/secrets.nix
sops.secrets."api/github_token" = {
  owner = config.users.users.pixel-peeper.name;
  mode = "0400";
};
```

Secret is automatically decrypted to `/run/secrets/api/github_token` during rebuild.

## Key Management

Your age key is stored at: `~/.config/sops/age/keys.txt`

**IMPORTANT**: This file is in `.gitignore` and should NEVER be committed to git.

### Backup Your Key

```bash
# Backup age key (store securely offline)
cp ~/.config/sops/age/keys.txt ~/backups/age-key-backup.txt

# Or encrypt the backup with a password
age -p ~/.config/sops/age/keys.txt > ~/backups/age-key-encrypted.age
```

### Restore on New Machine

```bash
# Restore age key
mkdir -p ~/.config/sops/age
cp ~/backups/age-key-backup.txt ~/.config/sops/age/keys.txt
```

## Adding a New Secret

1. **Create/Edit the unencrypted file**:
   ```bash
   sops secrets/hosts/alucard.yaml
   ```

2. **Add your secret**:
   ```yaml
   my_new_secret: "actual-secret-value"
   ```

3. **Save** - SOPS automatically encrypts on save

4. **Reference in NixOS**:
   ```nix
   sops.secrets."my_new_secret" = {
     owner = "root";
     mode = "0400";
   };
   ```

5. **Use in configuration**:
   ```nix
   config.services.my-service.configFile = config.sops.secrets."my_new_secret".path;
   ```

## Security Best Practices

✅ **DO**:
- Always encrypt before committing
- Backup age key securely offline
- Use minimal permissions (0400 for files)
- Rotate keys periodically
- Use separate keys for different environments (dev/prod)

❌ **DON'T**:
- Commit unencrypted secret files
- Commit age private keys
- Share private keys over unsecured channels
- Use the same key across multiple environments

## Troubleshooting

### "No decryption key available"

**Solution**: Ensure your age key is at `~/.config/sops/age/keys.txt`

```bash
ls -la ~/.config/sops/age/keys.txt
```

### "Failed to decrypt with age"

**Solution**: Check `.sops.yaml` has correct public key:

```bash
age-keygen -y ~/.config/sops/age/keys.txt
# Should match the public key in secrets/.sops.yaml
```

### "Permission denied" in NixOS

**Solution**: Check owner/mode in `secrets.nix`:

```nix
sops.secrets."my_secret" = {
  owner = "correct-user";  # Must be valid user
  mode = "0400";
};
```

## References

- [SOPS Documentation](https://github.com/getsops/sops/blob/master/README.rst)
- [Age Documentation](https://github.com/FiloSottile/age/blob/main/README.md)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [NixOS sops module](https://search.nixos.org/options?query=sops)


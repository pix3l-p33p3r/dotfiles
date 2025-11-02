# Secrets Management

Encrypted secrets managed with SOPS + Age.

## Overview

- **SOPS**: YAML/JSON file encryption
- **Age**: Modern encryption tool
- **sops-nix**: NixOS integration

## Structure

```
secrets/
├── .sops.yaml          # SOPS configuration
├── hosts/              # Host secrets
│   └── alucard.yaml
└── users/              # User secrets
    └── pixel-peeper.yaml
```

## Usage

**Edit a secret** (auto-decrypts/encrypts):
```bash
sops secrets/hosts/alucard.yaml
```

**Decrypt to stdout**:
```bash
sops -d secrets/hosts/alucard.yaml
```

**Use in NixOS**:
```nix
# machines/alucard/secrets.nix
sops.secrets."github_token" = {
  owner = config.users.users.pixel-peeper.name;
  mode = "0400";
};
```

Secret decrypted to `/run/secrets/github_token` at rebuild.

## Key Management

**Location**: `~/.config/sops/age/keys.txt`  
**⚠️ NEVER commit this file to git**

**Backup key**:
```bash
cp ~/.config/sops/age/keys.txt ~/backups/
```

**Restore on new machine**:
```bash
mkdir -p ~/.config/sops/age
cp ~/backups/keys.txt ~/.config/sops/age/keys.txt
```

## Security

✅ Age keys in `.gitignore`  
✅ Encrypted files safe to commit  
✅ Decryption at build time  
⚠️ Lose key = lose secrets (backup!)

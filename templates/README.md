# Ephemeral toolchains (devenv)

Rust and Lean no longer live permanently on goinfre.

| Tool | How | Where bits live | Free when done |
|------|-----|-----------------|----------------|
| **Rust** | `devenv shell` → nixpkgs `rustc`/`cargo` | `/nix/store` (goinfre) | `toolchain-gc rust` |
| **Lean** | `devenv shell` → nixpkgs `elan` | hynix `$ELAN_HOME` | `toolchain-gc lean` |

## Per project

```bash
# Rust
cp -r ~/dotfiles-terminal/templates/devenv-rust/{devenv.nix,devenv.yaml,.envrc} .
devenv shell          # or: direnv allow

# Lean (Lake)
cp -r ~/dotfiles-terminal/templates/devenv-lean/{devenv.nix,devenv.yaml,.envrc} .
devenv shell
```

Wired already: `Matrix`, `Computor-v2`, `Ready-Set-Boole-`, `Ready-Set-Boole-Lean`.

## GC

```bash
toolchain-gc status
toolchain-gc lean     # wipe hynix Lean toolchains
toolchain-gc rust     # drop .devenv roots + nix-collect-garbage -d
toolchain-gc all
```

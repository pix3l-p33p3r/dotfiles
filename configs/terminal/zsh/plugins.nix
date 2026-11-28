# Zap and its plugins pinned by rev + hash, so a shell never clones at startup.
# To bump one: change rev, set hash = lib.fakeHash, rebuild, paste the hash.
{
  lib,
  fetchFromGitHub,
  linkFarm,
  writeText,
}:
let
  gh =
    owner: repo: rev: hash:
    fetchFromGitHub { inherit owner repo rev hash; };

  zap = gh "zap-zsh" "zap" "d8e74d3d97ded884d14079f98f0a328580e4f8dc" "sha256-S0PoEwaw0o8tbQHdlNtF7VYWXv1an8Ljkiy0+sNdBmc=";

  # Keys are the repo names `plug "owner/repo"` looks up in $ZAP_PLUGIN_DIR.
  plugins = {
    agkozak-zsh-prompt = gh "agkozak" "agkozak-zsh-prompt" "2055c42a6e2f5bdc6e8dc4b453b0084ced3f471a" "sha256-C9lyOm2+RVLOUSO5Vz013uTobnN+SBE1Jm8GuJZ7T7U=";
    "calc.plugin.zsh" = gh "arzzen" "calc.plugin.zsh" "5b4c85977b693c15eb052cde6b5cef0d6610f567" "sha256-N4FBN7iyyiEyZX/opj63D5acA1Oh0YpFXdz83oIOWPE=";
    zsh-autopair = gh "hlissner" "zsh-autopair" "449a7c3d095bc8f3d78cf37b9549f8bb4c383f3d" "sha256-3zvOgIi+q7+sTXrT+r/4v98qjeiEL4Wh64rxBYnwJvQ=";
    zsh-autosuggestions = gh "zsh-users" "zsh-autosuggestions" "85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5" "sha256-KmkXgK1J6iAyb1FtF/gOa0adUnh1pgFsgQOUnNngBaE=";
    zsh-completions = gh "zsh-users" "zsh-completions" "989b23277ab33e8d5e82df6aed936e846db9d8b8" "sha256-H25tD8EAj7PRjGaUh8DDtMdSTRTAtzu4VS5Ka0ApCp0=";
    zsh-directory-dot-expansion = gh "wazum" "zsh-directory-dot-expansion" "fda62b133a197288c61672eb6c98379ca8513c13" "sha256-Hs4n43ceJoTKrh6Z4b/ozZ0McL0IXgdufljRtP++dVs=";
    zsh-history-substring-search = gh "zsh-users" "zsh-history-substring-search" "a0bdb0d47dbaba31dba2db7af8c48a5d9c74049a" "sha256-zJYTmlZy/b40dX1ZIeEo0/Vianm0Call04uwJDD1rYw=";
    zsh-syntax-highlighting = gh "zsh-users" "zsh-syntax-highlighting" "e6683f20e5c38d3e5447f45845d04ddda75d0f23" "sha256-ekCMmobd/OaCYStIoEx0l0HEn+6cD98jPlG8lMLl5bQ=";
    zsh-system-clipboard = gh "kutsan" "zsh-system-clipboard" "e2c3cbf3ccfff9bd0394391a29af5de88cd00b35" "sha256-l8HyXwrop6Px9nh7Z02Gvfksk0ZH/pHXzStKi6DwiQk=";
    zsh-vi-mode = gh "jeffreytse" "zsh-vi-mode" "91cafe4a09b6670cb8e761aa413e5f7b9e00816f" "sha256-5ZYcxl5sjfn1XfQ7D28Si4OXwCHHapAJSboJfNgl/5A=";
  };

  env = linkFarm "zap-env" (
    [
      {
        name = "zap.zsh";
        path = "${zap}/zap.zsh";
      }
      {
        name = "completion";
        path = "${zap}/completion";
      }
    ]
    ++ lib.mapAttrsToList (name: path: {
      name = "plugins/${name}";
      inherit path;
    }) plugins
  );
in
{
  inherit env;
  init = writeText "plugins.zsh" ''
    # Generated from configs/terminal/zsh/plugins.nix.
    if [[ -r ${env}/zap.zsh ]]; then
      source ${env}/zap.zsh
      ZAP_DIR=${env} ZAP_PLUGIN_DIR=${env}/plugins
      fpath+=(${env}/completion)
    else
      # Host shell before this machine has its Nix store: no plugins, shell still works.
      plug() { :; }
    fi
  '';
}

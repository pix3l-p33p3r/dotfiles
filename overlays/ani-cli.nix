final: prev: {
  ani-cli = prev.ani-cli.overrideAttrs (old: {
    version = "4.12";

    src = prev.fetchFromGitHub {
      owner = "pystardust";
      repo = "ani-cli";
      tag = "v4.12";
      hash = "sha256-ELGjAp4YGgPLN62g7Fgkb83CMotAGeRnRgIGU8rd73E=";
    };

    runtimeInputs = (old.runtimeInputs or [ ]) ++ [ prev.openssl ];
  });
}

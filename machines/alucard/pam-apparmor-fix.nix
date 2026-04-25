{ lib, config, ... }:

let
  enabledServices = lib.filterAttrs (name: svc: svc.enable) config.security.pam.services;
in
{
  # This option is defined in nixos/modules/security/pam.nix
  # We are overriding it here to fix a build issue where a patch
  # was no longer applying cleanly.
  # The original patch was intended to filter out non-absolute modulePaths
  # for AppArmor's PAM abstraction, but it was failing after an
  # upstream change in nixpkgs.
  # This override implements the intended logic directly, which is more robust.
  security.apparmor.includes."abstractions/pam" =
    lib.concatMapStrings (name: "r ${config.environment.etc."pam.d/${name}".source},\n") (
      lib.attrNames enabledServices
    )
    + (
      with lib;
      pipe enabledServices [
        lib.attrValues
        (catAttrs "rules")
        (concatMap lib.attrValues)
        (concatMap lib.attrValues)
        (filter (rule: rule.enable))
        (filter (
          rule:
          !builtins.elem rule.control [
            "include"
            "substack"
          ]
        ))
        (catAttrs "modulePath")
        (filter (mp: hasPrefix "/" mp)) # This is the fix
        unique
        (map (module: "mr ${module},"))
        concatLines
      ]
    );
}

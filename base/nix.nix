{ pkgs, ... }:

{
  time.timeZone = "Europe/Copenhagen";

  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      # Parallel build configuration
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;

      # Aggressive caching settings
      keep-outputs = true;
      keep-derivations = true;

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://thomaschrstnsn.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "thomaschrstnsn.cachix.org-1:jPfgdkADpT48y0uP/E3fPKCJuHHDe/JpRJrfyEYdxPA="
      ];
    };
  };
}

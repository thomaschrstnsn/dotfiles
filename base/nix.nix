{ pkgs, ... }:

{
  time.timeZone = "Europe/Copenhagen";

  nixpkgs.config.allowUnfree = true;

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
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://wezterm.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "thomaschrstnsn.cachix.org-1:jPfgdkADpT48y0uP/E3fPKCJuHHDe/JpRJrfyEYdxPA="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
      ];
    };
  };
}

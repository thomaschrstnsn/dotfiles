{ pkgs, ... }:

{
  time.timeZone = "Europe/Copenhagen";

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
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

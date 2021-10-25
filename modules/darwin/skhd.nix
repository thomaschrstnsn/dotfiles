{ pkgs, config, lib, ... }:
with lib;

{
  environment.systemPackages =
    [ 
      pkgs.jq
    ];
  environment.etc."skhd-moveWindowToDisplayAndFollowFocus.sh".source = ./skhd/moveWindowToDisplayAndFollowFocus.sh;
  environment.etc."skhd-moveWindowToSpaceOnSameDisplay.sh".source = ./skhd/moveWindowToSpaceOnSameDisplay.sh;
  environment.etc."skhd-toggleLayoutOnCurrentSpace.sh".source = ./skhd/toggleLayoutOnCurrentSpace.sh;

  services.skhd = {
    enable = true;
    # https://github.com/koekeishiya/skhd/issues/1
    skhdConfig = (builtins.readFile ./skhd/skhdrc);
  };
}

{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ 
      pkgs.jq
    ];

  
  services.yabai = {
    enable = false;
    package = pkgs.yabai;

    # https://github.com/koekeishiya/yabai/blob/master/doc/yabai.asciidoc#window
    config = {
      focus_follows_mouse          = "off";
      mouse_follows_focus          = "off";
      window_placement             = "second_child";
      window_opacity               = "off";
      window_opacity_duration      = "0.0";
      window_border                = "off";
      window_border_placement      = "inset";
      window_border_width          = 4;
      window_border_radius         = 3;
      active_window_border_topmost = "off";
      window_topmost               = "on";
      window_shadow                = "float";
      active_window_border_color   = "0xff00FF00";
      normal_window_border_color   = "0x00505050";
      insert_window_border_color   = "0x00d75f5f";
      active_window_opacity        = "1.0";
      normal_window_opacity        = "1.0";
      split_ratio                  = "0.50";
      auto_balance                 = "on";
      mouse_modifier               = "cmd";
      mouse_action1                = "move";
      mouse_action2                = "resize";
      layout                       = "bsp";
      top_padding                  = 10;
      bottom_padding               = 10;
      left_padding                 = 10;
      right_padding                = 10;
      window_gap                   = 10;
    };

    extraConfig = ''
        yabai -m rule --add app='System Preferences' manage=off
        yabai -m rule --add app='Finder' manage=off
        yabai -m rule --add title='Preferences$' manage=off
        yabai -m rule --add app='Calculator' manage=off

        yabai -m rule --add title='Go to Line:Column' manage=off # Rider

        # defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    '';
  };

#   environment.etc."skhd-moveWindowToDisplayAndFollowFocus.sh".source = ./skhd-scripts/moveWindowToDisplayAndFollowFocus.sh;
#   environment.etc."skhd-moveWindowToSpaceOnSameDisplay.sh".source = ./skhd-scripts/moveWindowToSpaceOnSameDisplay.sh;
#   environment.etc."skhd-toggleLayoutOnCurrentSpace.sh".source = ./skhd-scripts/toggleLayoutOnCurrentSpace.sh;

#   services.skhd = {
#     enable = true;
#     # https://github.com/koekeishiya/skhd/issues/1
#     skhdConfig = (builtins.readFile ./skhdrc);
#   };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";
  
  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
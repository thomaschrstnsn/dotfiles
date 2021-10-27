{ pkgs, config, lib, ... }:
{
  services.yabai = {
    enable = true;
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
        # yabai -m rule --add title='AppGate SDP$' manage=off
        yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
        yabai -m rule --add title='Go to Line:Column' manage=off # Rider

        # defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    '';
  };
}

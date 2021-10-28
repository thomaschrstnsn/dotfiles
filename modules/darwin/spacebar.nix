{ pkgs, config, lib, ... }:
{
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    position                   = "bottom";
    display                    = "main";
    height                     = 26;
    title                      = "on";
    spaces                     = "on";
    clock                      = "on";
    power                      = "on";
    padding_left               = 20;
    padding_right              = 20;
    spacing_left               = 25;
    spacing_right              = 15;
    text_font                  = ''"MesloLGS NF:Regular:12.0"'';
    icon_font                  = ''"MesloLGS NF:Regular:12.0"'';
    background_color           = "0xff202020";
    foreground_color           = "0xffa8a8a8";
    power_icon_color           = "0xffcd950c";
    battery_icon_color         = "0xffd75f5f";
    dnd_icon_color             = "0xffa8a8a8";
    clock_icon_color           = "0xffa8a8a8";
    power_icon_strip           = " ";
    space_icon                 = "•";
    space_icon_strip           = "1 2 3 4 5 6 7 8 9 10";
    spaces_for_all_displays    = "on";
    display_separator          = "on";
    display_separator_icon     = "";
    #space_icon_color           = "0xff458588";
    space_icon_color           = "0xfff55f42"; # keychron k2v2 accent
    space_icon_color_secondary = "0xff78c4d4";
    space_icon_color_tertiary  = "0xfffff9b0";
    clock_icon                 = "";
    dnd_icon                   = "";
    clock_format               = ''"W%U %d/%m/%y %R"'';
    right_shell                = "on";
    right_shell_icon           = "";
    right_shell_command        = "/etc/spacebar-cpu-usage.sh";
  };

  environment.etc."spacebar-cpu-usage.sh".source = ./spacebar/cpu-usage.sh;

  # for debugging
  # services.spacebar.config.debug_output = "on";
  # launchd.user.agents.spacebar.serviceConfig.StandardErrorPath = "/tmp/spacebar.err.log";
  # launchd.user.agents.spacebar.serviceConfig.StandardOutPath = "/tmp/spacebar.out.log";

  services.yabai.config = {
      external_bar = "main:0:26";
  };

  system.defaults.NSGlobalDomain = {
    _HIHideMenuBar = true;
  };
}
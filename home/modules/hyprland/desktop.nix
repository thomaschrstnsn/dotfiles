# Fonts, packages and theming around the hyprland session.
{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  mkIfList = cond: xs: if cond then xs else [ ];

  cfg = config.tc.hyprland;

  inherit (import ./commands.nix { inherit pkgs cfg; }) useHyprlock hyprlockFix;
in
{
  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    # check up on font installation nixos vs home-manager: https://nixos.wiki/wiki/Fonts
    # fonts.packages = with pkgs; [];

    home.packages = with pkgs; (concatLists [
      [
        myPkgs.appleFonts.sf-pro
        bemoji # emoji picker
        nerd-fonts.jetbrains-mono
        noto-fonts
        font-awesome
        jq # for scripts
        libnotify
        overskride # bluetooth
        openhue-cli
        pavucontrol
        pulseaudio
        wl-clipboard
        wtype # dep for bemoji
      ]
      (mkIfList (cfg.shell == "hyprpanel") [
        hyprpanel
        python312Packages.gpustat
      ])
      (mkIfList (cfg.clipboard == "clipse") [ clipse ])
      (mkIfList (cfg.screenshot == "hyprshot") [ hyprshot ])
      (mkIfList useHyprlock [ hyprlockFix ])
      (mkIfList cfg.hyprfocus.enable [ myPkgs.hyprfocus ])
      (mkIfList cfg.laptop.brightnessKeys [ brightnessctl ])
    ]);

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    programs.wofi = mkIf (cfg.launcher == "wofi") {
      enable = true;
      style = readFile ./wofi/style.css;
    };

    gtk = rec {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;

      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
      };

      # does not seem fully baked, seems to need env
      # GTK_THEME=Adwaita:dark nautilus
      # GTK_THEME=Adwaita:dark gnome-calculator
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      gtk4.theme = theme;
    };
  };
}

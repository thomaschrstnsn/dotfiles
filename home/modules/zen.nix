{ config, lib, ... }:

with lib;

let
  cfg = config.tc.zen;

  # macOS-style: super (meta) instead of ctrl for common shortcuts
  super = id: key: { inherit id key; modifiers.meta = true; };
  superShift = id: key: { inherit id key; modifiers = { meta = true; shift = true; }; };
  unbind = id: { inherit id; disabled = true; };

  keyboardShortcuts = [
    (super "key_newNavigatorTab" "t")
    (super "key_newNavigator" "n")
    (superShift "key_privatebrowsing" "n")
    (super "key_close" "w")
    (superShift "key_restoreLastClosedTabOrWindowOrSession" "t")
    (super "focusURLBar" "l")
    (super "key_find" "f")
    (super "key_reload" "r")
    (superShift "key_reload_skip_cache" "r")
    (super "zen-compact-mode-toggle" "s")
    (superShift "zen-compact-mode-show-sidebar" "s")

    (unbind "key_quitApplication")
    (unbind "key_gotoHistory")
    (unbind "key_findAgain")
    (unbind "key_findPrevious")
  ] ++ map (n: unbind "zen-workspace-switch-${toString n}") (range 1 10);
in
{
  options.tc.zen = with types; {
    enable = mkEnableOption "Zen browser (via zen-browser-flake home-manager module)";
    profilePath = mkOption {
      type = str;
      default = "default";
      description = "Directory name of the profile under ~/.config/zen (point at an existing profile to keep its data).";
    };
  };

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        path = cfg.profilePath;
        inherit keyboardShortcuts;
      };
    };
  };
}

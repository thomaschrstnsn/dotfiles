# Commands and helpers derived from the chosen shell/launcher/lockscreen etc.
# Shared between the files of the hyprland module.
{ pkgs, cfg }:
{
  clipseClass = "name.savedra1.clipse";

  lockCmd = {
    hyprlock = "pidof hyprlock || env WLR_EGL_NO_MODIFIERS=1 hyprlock";
    noctalia = "noctalia-shell ipc call lockScreen lock";
  }.${cfg.lockscreen};

  useHyprlock = cfg.lockscreen == "hyprlock";

  launcherCmd = {
    wofi = "pgrep wofi || wofi --show run";
    noctalia = "noctalia msg panel-toggle launcher";
  }.${cfg.launcher};

  screenshotCmd = {
    hyprshot = "hyprshot -m region --clipboard-only";
    noctalia = "noctalia msg screenshot-region";
  }.${cfg.screenshot};

  terminal = {
    executable = term: term;
    class = term: {
      wezterm = "org.wezfurlong.wezterm";
      ghostty = "com.mitchellh.ghostty";
    }.${term};
    starter = term: { class, command }: {
      wezterm = "wezterm start --class ${class} -e '${command}'";
      ghostty = "ghostty --class=${class} -e '${command}'";
    }.${term};
  };

  webapp = {
    starter = app: "${pkgs.gtk3}/bin/gtk-launch ${app}.desktop";
    # class = app: "webapp-${app}";
  };

  hyprlockFix = pkgs.writeShellApplication {
    name = "hyprlock-fix";
    text = ''
      pkill -9 hyprlock
      hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'
    '';
  };
}

{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.webapps;

  disableSameSiteByDefaultCookies = "--disable-features=SameSiteByDefaultCookies";

  mkDesktopEntry = url: name: extraOptions: {
    inherit name;
    exec = "${pkgs.chromium}/bin/chromium  --app=${url} --enable-features=WebAppInstallation ${extraOptions}";
    icon = "applications-internet";
    categories = [ "Application" ];
    terminal = false;
  };
in
{
  options.tc.webapps = {
    enable = mkEnableOption "webapps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        gtk3 # gtk-launch
      ];
    xdg = {
      enable = true;
      mime.enable = true;
      desktopEntries = {
        claude = mkDesktopEntry "https://claude.ai" "Claude" "";
        icloud-calendar = mkDesktopEntry "https://www.icloud.com/calendar/" "iCloud Calendar" disableSameSiteByDefaultCookies;
      };
    };

  };
}


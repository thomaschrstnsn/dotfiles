{ pkgs, ... }:
{
  home-manager.users.thomas = {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
    };
  };
}

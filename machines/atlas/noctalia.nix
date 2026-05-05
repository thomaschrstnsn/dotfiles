{ ... }:
{
  home-manager.users.thomas = {
    programs.noctalia-shell = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ./noctalia/settings.json);
    };
  };
}

{ ... }:
{
  home-manager.users.thomas = {
    programs.noctalia-shell = {
      enable = true;
      # noctalia-shell ipc call state all | jq .settings
      settings = builtins.fromJSON (builtins.readFile ./noctalia/settings.json);
    };
  };
}

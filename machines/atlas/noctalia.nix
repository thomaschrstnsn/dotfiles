{ ... }:
{
  home-manager.users.thomas = {
    programs.noctalia = {
      enable = true;
      # noctalia config export > machines/atlas/noctalia/config.toml
      settings = builtins.readFile ./noctalia/config.toml;
    };
  };
}

{ systems, ... }:

let
  username = "nixos";
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/${username}";
    };
    dotnet = {
      enable = true;
      sdks = [ "7.0" "8.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" ];
      agent.enable = true;
    };
    tmux = {
      enable = true;
    };
    wsl.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
    vim = {
      enable = true;
      # lsp.servers.csharp = true;
      lsp.servers.omnisharp = true;
    };
    direnv.enable = true;
  };
  extraPackages = pkgs: with pkgs; [
    k9s
    kubernetes-helm
    kubectl
    nerdctl
    pulsarctl
    unzip
    zip
  ];

  system = systems.x64-linux;

  nixos = {
    config = {
      user = {
        name = username;
        groups = [ "wheel" ];
      };
      networking.hostname = "PC04236";
    };
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };
}

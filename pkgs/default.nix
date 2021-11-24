{ pkgs, forgit-git, ... }:
with pkgs;
let
  buildDotnet = attrs: callPackage (import ./build-dotnet.nix attrs) { };
  buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
  buildNetCore = attrs: buildDotnet (attrs // { type = "netcore"; });
  buildNetCoreSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
in
{
  myPkgs = {
    zsh-forgit = callPackage ./zsh-forgit { inherit forgit-git; };
    dotnet.sdk_2_2 = buildNetCoreSdk {
      version = "2.2.207";
      sha512 = {
        x86_64-linux = "sha512-nXC0qKY7ZtqQVECHGZoPaB0TW/kNQ8pTsS6pfMYAp2iwo9L4JM/ie9MijgWLBgxjMZzYYDO+i40nklKD+Z3pWA==;";
        aarch64-linux = lib.fakeSha512;
        x86_64-darwin = "2pafmx09mjri25v4xidnhhnbygy1r9bw8sj0z5mp2blw2nc5q9ddqzp8k51sjscwv3mxzhy3vqsc8wj44swdj6a1brsh25sa4w6h3fn";
      };
    };
  };
}

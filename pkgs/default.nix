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
    dotnet.sdk_2_2 = buildNetCoreSdk
      {
        version = "2.2.207";
        sha512 = {
          x86_64-linux = "sha512-nXC0qKY7ZtqQVECHGZoPaB0TW/kNQ8pTsS6pfMYAp2iwo9L4JM/ie9MijgWLBgxjMZzYYDO+i40nklKD+Z3pWA==;";
          aarch64-linux = lib.fakeSha512;
          x86_64-darwin = "2pafmx09mjri25v4xidnhhnbygy1r9bw8sj0z5mp2blw2nc5q9ddqzp8k51sjscwv3mxzhy3vqsc8wj44swdj6a1brsh25sa4w6h3fn";
        };
      };
    dotnet.sdk_6_0 = buildNetCoreSdk {
      version = "6.0.100";
      sha512 = {
        x86_64-linux = "cb0d174a79d6294c302261b645dba6a479da8f7cf6c1fe15ae6998bc09c5e0baec810822f9e0104e84b0efd51fdc0333306cb2a0a6fcdbaf515a8ad8cf1af25b";
        aarch64-linux = "e5983c1c599d6dc7c3c7496b9698e47c68247f04a5d0d1e3162969d071471297bce1c2fd3a1f9fb88645006c327ae79f880dcbdd8eefc9166fd717331f2716e7";
        x86_64-darwin = "6e2f502a84f712d60daed31c4076c5b55ee98a03259adf4bdc01659afcac2be7050e5a404dcda35fdc598bf5cd766772c08abc483ed94f6985c9501057b0186a";
        aarch64-darwin = "92ead34c7e082dbed2786db044385ddfc68673e096a3edf64bc0bf70c76ea1c5cb816cde99aab2d8c528a44c86593b812877d075486dd0ae565f0e01e9eaa562";
      };
    };
  };
}

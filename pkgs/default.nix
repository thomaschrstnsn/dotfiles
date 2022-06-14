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
        aarch64-linux = "565fe5cbc2c388e54b3ee548d5b98e1fd85d920ceeeb5475a2bf2daa7f090fc925d8afef19b2b76973af439fbb749c6996711790287eafd588e4d916a016e84c";
        x86_64-darwin = "2pafmx09mjri25v4xidnhhnbygy1r9bw8sj0z5mp2blw2nc5q9ddqzp8k51sjscwv3mxzhy3vqsc8wj44swdj6a1brsh25sa4w6h3fn";
      };
    };

    dotnet.sdk_3_1 = buildNetCoreSdk {
      version = "3.1.419";
      sha512 = {
        x86_64-linux = "957d9561b346226806270a969a302217dec2a5e4853225d73fbf85f20f6107137ac5678a6ffdf5c170a72f5ef93e3defe3218970bc20d97a4f880d5c7577376f";
        aarch64-linux = "94f398c09b53c10dc3e4ed1f624eee19b18770734956ebb0cb4ac9d789c1a79a891c1934e7c4c3a2bed5326ee1a0417ee89816695ab2436b3db7076328a40b77";
        x86_64-darwin = "8e838fcd15d5d170bcb75e8e3cb14b626965ebe1ba58af8605b951461e0dc11d97d05c2cd76777978c72d0109c476e0cedf82772d445987697a7e23d3c7f0b1a";
      };
    };

    dotnet.sdk_6_0 = buildNetCoreSdk {
      version = "6.0.300";
      sha512 = {
        x86_64-linux = "52d720e90cfb889a92d605d64e6d0e90b96209e1bd7eab00dab1d567017d7a5a4ff4adbc55aff4cffcea4b1bf92bb8d351859d00d8eb65059eec5e449886c938";
        aarch64-linux = "67eb088ccad197a39f104af60f3e6d12ea9b17560e059c0f7c8e956005d919d00bf0f3e487b06280be63ad57aa8895f16ebc8c92107c5019c9cf47bd620ea925";
        aarch64-darwin = "sha512-F0zsv9/NEYfKceW3QerazA4QPOp1Ji990V/atoRSJs7I3vdc9MvsPcB70IXQA6xFZnARWy8qSoj5Ar6KXDuzrg==";
        x86_64-darwin = "sha512-NhGGc84aSc8xZYRE8ptn38M4t460aEekPzjeCuaM8uTXIDmxgTqJct4xzYz+oTqYYdB1OE5nuG+Y/2q7kPS9Lg==";
      };
    };
  };
}

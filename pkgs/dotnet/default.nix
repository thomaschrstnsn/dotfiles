{ pkgs, ... }:

with pkgs;
let
  buildDotnet = attrs: callPackage (import ./build-dotnet.nix attrs) { };
  buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
  buildNetCore = attrs: buildDotnet (attrs // { type = "netcore"; });
  buildNetCoreSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
in
{
  # ./print-dotnet-hashes.sh 2.2 3.1 6.0
  sdk_2_2 = buildNetCoreSdk {
    version = "2.2.207";
    sha512 = {
      x86_64-linux = "sha512-nXC0qKY7ZtqQVECHGZoPaB0TW/kNQ8pTsS6pfMYAp2iwo9L4JM/ie9MijgWLBgxjMZzYYDO+i40nklKD+Z3pWA==;";
      aarch64-linux = "565fe5cbc2c388e54b3ee548d5b98e1fd85d920ceeeb5475a2bf2daa7f090fc925d8afef19b2b76973af439fbb749c6996711790287eafd588e4d916a016e84c";
      x86_64-darwin = "2pafmx09mjri25v4xidnhhnbygy1r9bw8sj0z5mp2blw2nc5q9ddqzp8k51sjscwv3mxzhy3vqsc8wj44swdj6a1brsh25sa4w6h3fn";
    };
  };

  sdk_3_1 = buildNetCoreSdk {
    version = "3.1.420";
    sha512 = {
      x86_64-linux = "b3bdd964182f9edc3c2976541e657fcc43b0eaf9bc97197597c7ecb8b784d79e3efb9e0405c84e1dcb434cf4cd38ddc4af628c5df486c3d7ae8a23e5254796e3";
      aarch64-linux = "ac66b1544fe178153bb85c2e5be584464374ce4c036fc95720547c231c2730312018fbdfc735f9071579749415bc54e1f6b8f080cc2b08d5799a0da941e8a5f5";
      x86_64-darwin = "370cba4685e07d1cdb5d7f9b754812b237802ace679c9b9985c6e5c4dc09f500580f1413679a288615079bd155b68b362adb00151b2b8f5ca7c3718ab9e16194";
    };
  };

  sdk_6_0 = buildNetCoreSdk {
    version = "6.0.301";
    sha512 = {
      x86_64-linux = "2f434ea4860ee637e9cf19991a80e1febb1105531dd96b4fbc728d538ca0ab202a0bdff128fd13b269fac3ba3bc9d5f9c49039a6e0d7d32751e8a2bb6d790446";
      aarch64-linux = "978dd04f78ac3d6b594c47f1482bba0abe93f0b37379c1c46a2b9b33bdf5188576b055250546295de39bb22cba93ea9b31c31bb026a319ad1b3fc507db44481f";
      x86_64-darwin = "027328a353b65fad0618d1e5abeb973c9f05787d9432631bf9ab5fafe636ea2f494f70c0704e81a1664fe7a3519174bd269dbc795b651b14e9a86c83f8e3adec";
      aarch64-darwin = "899558be856769ad6ccc4606f3a9f996327a7395a72acb18a5fb0899e0c4c4ba8c90b94f16771439193f87a974e1e884dd55a9fc6649fe929ebe47ef19cb4efc";
    };
  };
}

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
    version = "3.1.421";
    sha512 = {
      x86_64-linux = "9f592db89ddfdfa3254d59c39f227109e0f87f156a8ab00595bcf332fdebd3e873fb9e07c875905aaa8ba5022e6e551e2d9516cfb855d04ec781313521595431";
      aarch64-linux = "c584642469343c2c54fa02a7157009fa36bae9b304512db0a2b0069f71593ee2ba47070896212def0541460f37bf1b0a478b914e08a2c78b985cb2981e5ab6c6";
      x86_64-darwin = "706c3a5d573c4adf6fe2e34891a4909877ebcd2fea46228f714232cf414c72814ae3a83c82f863434b494f9306010e11142135e042d61cd1739acffb18c310c3";
    };
  };

  sdk_6_0 = buildNetCoreSdk {
    version = "6.0.302";
    sha512 = {
      x86_64-linux = "ac1d124802ca035aa00806312460b371af8e3a55d85383ddd8bb66f427c4fabae75b8be23c45888344e13b283a4f9c7df228447c06d796a57ffa5bb21992e6a4";
      aarch64-linux = "26e98a63665d707b1a7729f1794077316f9927edd88d12d82d0357fe597096b0d89b64a085fcdf0cf49807a443bbfebb48e10ea91cea890846cf4308e67c4ea5";
      x86_64-darwin = "003a06be76bf6228b4c033f34773039d57ebd485cf471a8117f5516f243a47a24d1b485ab9307becc1973107bb1d5b6c3028bbcbb217cbb42f5bee4c6c01c458";
      aarch64-darwin = "59caea897a56b785245dcd3a6082247aeb879c39ecfab16db60e9dc3db447ca4e3ebe68e992c0551af886cd81f6f0088cb1433f1be6df865afa357f90f37ccf6";
    };
  };
}

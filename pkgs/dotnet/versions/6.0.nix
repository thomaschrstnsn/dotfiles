{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.15";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4518a0d8-9a6b-4836-ada9-096afa24efd0/ad0d8ccefb6b6a36dc108417b74775cb/aspnetcore-runtime-6.0.15-linux-x64.tar.gz";
        sha512  = "db41bbd6ffb061402acee12f498f41fe5987d355c9004091ff63010303cc9ea969ab233986dc11556bc6def5194883f50fdf216e1c50b26bb60cacd4f2ecd98a";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0d9619a1-af06-40c6-9816-46d08c9e42d6/744ecc09a1058822dc08ae17a3dc9c77/aspnetcore-runtime-6.0.15-linux-arm64.tar.gz";
        sha512  = "3968cc6984627a521e68658f61dd0d97caf061a2582b3a133e4d13ff90718954e881f1dd1180f48458550fb02e2122a71fb2bc0463bba38f6812e173202c2c68";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/183c7035-79ba-4438-a96f-39cebae901c7/14358a3d95afb3af618abea80a8106db/aspnetcore-runtime-6.0.15-osx-x64.tar.gz";
        sha512  = "2e73fc14f85e6cf01fd53439fdbb451496391530cf9af0b4775445383b6f70b5bacd78a0408a8cd6fda23569999fec5809a5cb6325f353fcf72cbb0524e0444e";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8c038a1c-2c5a-4223-b863-3c7ace6b96f0/92b7538b884350b055a22c7877775fa1/aspnetcore-runtime-6.0.15-osx-arm64.tar.gz";
        sha512  = "9295d3931af3b7b74c5fa2c61d49f0c270d00fbf0ab15d130f5b70e28297051341b390d36a1f09cc79a46f044099a3830f652d8a294239821d473f946d82ee25";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.15";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a8db1a39-3418-4bd3-871e-5d13509ee724/2fac3893cffd4948c67dc3a2ef96a99d/dotnet-runtime-6.0.15-linux-x64.tar.gz";
        sha512  = "681928ab5050da89302518445f4e7e00738530b3941434fad363724ad5b1f9bcdc52717332613d2e33733ebf835eb550628e87cebba1a12ffb4f881c8e767749";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2151a562-4991-4496-afac-12ae22e4710d/90644d83484758da592719d9946ca1b8/dotnet-runtime-6.0.15-linux-arm64.tar.gz";
        sha512  = "639153616c316832970b57faebb95a405d52549d60588a2e515323640a9ec0b7d5826a8434a7759ac890c841541f52551ae21895320749b80ab5ce29290d0c8f";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/002ce092-a45c-4c52-baae-067879173e64/a6b706f9b30cb74210ce87ca651b3f4b/dotnet-runtime-6.0.15-osx-x64.tar.gz";
        sha512  = "7aff9d90424433d35f4152dc6e31b974d35bf636547d4d1c93e7ada25703023a915a232010267842defcbeec95be0a0e0a11f568a07b225ee23dfcbff85cf898";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/b809e06f-b836-45d4-b080-06b263579478/4690f65020f04e6579085df1aad7421d/dotnet-runtime-6.0.15-osx-arm64.tar.gz";
        sha512  = "23043de9e69ee01570d7a99be997a38d43da69dc77a59945df780eae772b9f02d8d427062a3c9d0468a41f3783ce9755c1ebc5986f3e02bd661113ca3a3051e8";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.407";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/868b2f38-62ca-4fd8-93ea-e640cf4d2c5b/1e615b6044c0cf99806b8f6e19c97e03/dotnet-sdk-6.0.407-linux-x64.tar.gz";
        sha512  = "3cc230f21c0d60ffa4955c01d79cbb41887a41f4e97d0708170e4be8e4dc5bc261269c788c738416c28bbc7e8c6940a89cf3d010f16d1dc4cf25bbb0e2c033c1";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/72d1f83c-ad2c-4c9b-88b1-15196f411b9d/a0b863cabea9ac0fe7b92dc70c8d4ef0/dotnet-sdk-6.0.407-linux-arm64.tar.gz";
        sha512  = "7d48d8a3814694a978b09a7c4b61c8e0dae9b5efe8195c15339d2f777fa4b85084d386117ee03b05f543d3d64b9484942e1e212001382b2e67277b30f5254b9f";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/3309662c-cf75-4bae-9317-b0441971084a/91c1112b15c070c03a0d5e6f61434fc7/dotnet-sdk-6.0.407-osx-x64.tar.gz";
        sha512  = "3e4cfbd15ee138c8d1582ebd33a443edc7d8e055d579abc0335a288b2c26bac15d7e4fe3b80f91d56513c82318b6a62803558e3d41a28b6716d2296d12d3003c";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a23756f7-af64-424e-824f-35fd816a5144/0c7789d67cef2037efba35649d643004/dotnet-sdk-6.0.407-osx-arm64.tar.gz";
        sha512  = "75b2cd3a679c3d156ec9f7fdefa9637f8684be17254636acfdddb3bb3d56da4dbac05e9f178acf46a631a21ab96a270aa20256bb3518d89fdcdf6a8d3d21e73d";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

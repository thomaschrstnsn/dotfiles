{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.25";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0cf64d28-dec3-4553-b38d-8f526e6f64b0/0bf8e79d48da8cb4913bc1c969653e9a/aspnetcore-runtime-6.0.25-linux-x64.tar.gz";
        sha512  = "ea1e9ce3f90dbde4241d78422a4ce0f8865f44f870f205be26b99878c13d56903919f052dec6559c4791e9943d3081bc8a9fd2cf2ee6a0283f613b1bdecf69e1";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8f085f4e-ce83-494f-add1-7e6d4e04f90e/398b661de84bda4d74b5c04fa709eadb/aspnetcore-runtime-6.0.25-linux-arm64.tar.gz";
        sha512  = "fdd2e717963f213abbab6dcd367664ebedc2f2ec9c2433fca27c4d2eb7704a73d3f4ec5b354b24d5be77f3683605a56f5675d1d543c5f76d042a1353deab8d73";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/eb5d3ec0-10d3-4ed4-986a-9b350f200d7c/e59374e45f5f1be3c111f53c7e2ebb32/aspnetcore-runtime-6.0.25-osx-x64.tar.gz";
        sha512  = "d58721d8f0a7cf6538446b37ff6399c285e4fbbbc30ac0b550cada361ce2cbc981039e8c90e3d038de1886e91be5457acd5c88bd72008a208c62dd533080864d";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fab54ac5-5712-4c94-b9a7-68e18533b8ee/8197e36c3a2522e233e4d66c3a7b098b/aspnetcore-runtime-6.0.25-osx-arm64.tar.gz";
        sha512  = "ab9ccefa4d0249aa1ec313e02aa7dfec9b048f3db42881c808050efe3956749fdcadfbb937cfec19ac37fed70c81894dcf428a34b27c52e0cd2911fd98d29e9a";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.25";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0e8de3f9-7fda-46b7-9337-a3709c8e385d/bc29c53eb79fda25abb0fb9be60c6a22/dotnet-runtime-6.0.25-linux-x64.tar.gz";
        sha512  = "9d4cd137353b6340162ca2c381342957e22d6cb419af9198a09f2354ba647ce0ddd007c58e464a47b48ac778ffc2b77569d8ca7921d0819aa92a5ac69d99de27";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c5ebe66a-1815-4cdf-a099-af89dbf370b8/8162d0068512e14f69325d18ce10acb3/dotnet-runtime-6.0.25-linux-arm64.tar.gz";
        sha512  = "d7d5d9460cca02976b01b233e3bfca32f7739910dcbdab34ad035e7e0314204b84289a1ab11f82c36dcd517657749ec1fc4d4ead2c9ee0ab2ffabfc886f0e87a";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bb33d6bf-748c-47b0-8077-962fef12afc8/8a0fbc979b8bded0b4538d08e8f92916/dotnet-runtime-6.0.25-osx-x64.tar.gz";
        sha512  = "b9241a03aaa8ea56d54e3f1b13baabad9e3d6b2b16633f0c6c01d3513ec6ec7aadc455dc1bb7b096c7df75efcf54ef467e1fb8ad9f3777ad3b5236bfb0db0133";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5bb1393b-ffe1-4961-8d42-7272611a0399/6cb74b96d854a95fe4d42c62d359427c/dotnet-runtime-6.0.25-osx-arm64.tar.gz";
        sha512  = "b12e4e08d6f305e88bb7af385e5380b8bffbe190c4a17929d1bec18c37feb21298512dd24aa5b0f19b7cc775e9f54fa088ed0b22bdb05200f95ae6ca04e7d63e";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.417";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/1cac4d08-3025-4c00-972d-5c7ea446d1d7/a83bc5cbedf8b90495802ccfedaeb2e6/dotnet-sdk-6.0.417-linux-x64.tar.gz";
        sha512  = "997caff60dbad7259db7e3dd89886fc86b733fa6c1bd3864c8199f704eb24ee59395e327c43bb7c0ed74e57ec412bd616ea26f02f8f8668d04423d6f8e0a8a33";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/03972b46-ddcd-4529-b8e0-df5c1264cd98/285a1f545020e3ddc47d15cf95ca7a33/dotnet-sdk-6.0.417-linux-arm64.tar.gz";
        sha512  = "39cada75d9b92797de304987437498d853e1a525b38fa72d0d2949932a092fcf6036b055678686db42682b5b79cdc5ec5995cb01aa186762e081eb1ed38d2364";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c271e475-c02a-4c95-a3d2-d276ede0ba74/8eee5d06d92ed4ae73083aa55b1270a8/dotnet-sdk-6.0.417-osx-x64.tar.gz";
        sha512  = "f252050409f87851f744aa1779a58ebe340d45174aeb13d888068ffae053c5bcd261a89bcc8efc2d9c61751720bb4ca61cf19ac5346e8d23e7960a74d76cf00c";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f82f1323-a530-4dcd-9488-c73443f35198/e59be6f142903e5d562143b1ae8f2155/dotnet-sdk-6.0.417-osx-arm64.tar.gz";
        sha512  = "87aaee2a4047510f2267bbdafd226703066700131e25da95141e77b2725b7d1ec549384c763e0936c7f3162199144072c1b3fedb4cb58bd6864565e98ae1b955";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

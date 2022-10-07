{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v6.0 (lts)
{
  sdk_6_0 = buildNetSdk {
    inherit icu;
    version = "6.0.401";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8159607a-e686-4ead-ac99-b4c97290a5fd/ec6070b1b2cc0651ebe57cf1bd411315/dotnet-sdk-6.0.401-linux-x64.tar.gz";
        sha512  = "6fce5f29e6cfc80da1df86d2de3a637108023397d275e0dcfa0b79ef36eb85c2c3433db467aa5d8fda7e32bc21205a126636b53d56c4eb4c547d9d3b2370cb31";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a567a07f-af9d-451a-834c-a746ac299e6b/1d9d74b54cf580f93cad71a6bf7b32be/dotnet-sdk-6.0.401-linux-arm64.tar.gz";
        sha512  = "8c05f9e02e0a48fcc3e4534fa7225fe5b974c07f1a4788c46207e18e94031194e1c881e40452ee6c432764e92331c50ae47305d4aec5afa363fab3a8a6727cdf";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e79e447d-20fd-4ed9-992d-39165aaf964a/1f101c161bc4a931e16c697e3934e413/dotnet-sdk-6.0.401-osx-x64.tar.gz";
        sha512  = "6cc47bd279ba3d5e2df9f41b14b25662c8a3d61d5dee0fe021ad54a8709aa8a34430deb644c3525d66124a6a1bdf6a273008ea5fcbddccee238f4c470bac3e05";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/dfeaba35-b5b0-4299-b4fa-56735e3f224e/80cc6c2404d0319fb3eab5d0f407b169/dotnet-sdk-6.0.401-osx-arm64.tar.gz";
        sha512  = "0e1974a99863afe0b2c03fe52874ad388c3e019e34c7e0a1dc29955dfa9783a946082270fbd767272817509b30d1928d0c9f12cda43777292587693e0b0fc604";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

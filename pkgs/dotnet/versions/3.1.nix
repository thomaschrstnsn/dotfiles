{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v3.1 (eol)
{
  sdk_3_1 = buildNetSdk {
    inherit icu;
    version = "3.1.426";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e89c4f00-5cbb-4810-897d-f5300165ee60/027ace0fdcfb834ae0a13469f0b1a4c8/dotnet-sdk-3.1.426-linux-x64.tar.gz";
        sha512  = "6c3f9541557feb5d5b93f5c10b28264878948e8540f2b8bb7fb966c32bd38191e6b310dcb5f87a4a8f7c67a7046fa932cde3cce9dc8341c1365ae6c9fcc481ec";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/79f1cf3e-ccc7-4de4-9f4c-1a6e061cb867/68cab78b3f9a5a8ce2f275b983204376/dotnet-sdk-3.1.426-linux-arm64.tar.gz";
        sha512  = "300e154fba3123644910bbb89a6e61f67569677efa359aa110871cbbb62afad059709dc362f0af27ece0b9a30bc3e6ef57c3cb7c6f75377b20d48636605f30f7";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e45c25b7-623f-4b98-8918-13a671884860/d6e4526d0dd31d388b36a749f90ae6e2/dotnet-sdk-3.1.426-osx-x64.tar.gz";
        sha512  = "be1c29ffe8ddec6051d7529796dae35fe18036af89d5e7285fcdad46316fec557f4b15c15eed4d676071d187b363c2e16cb3bcbf708b920b5614340a6e51ab3d";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

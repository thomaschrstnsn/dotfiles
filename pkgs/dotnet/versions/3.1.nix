{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v3.1 (maintenance)
{
  sdk_3_1 = buildNetSdk {
    inherit icu;
    version = "3.1.423";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e137cdac-0e15-46ec-bd60-14fe6ad50c41/30c102677cc4bd0f117cc026781ec5e8/dotnet-sdk-3.1.423-linux-x64.tar.gz";
        sha512  = "bcb0efcc066a668eb390b57fd2c944abe73234fdbed57a4b1d21af5b880d102b765f2a790bb137d4b9f3d0d4e24fc53d39dc7666e665624c12e07d503c54ceae";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/11abab07-d7a2-46b0-9ab5-19d5db67212f/783196073ecbd9fd64378fec412affbe/dotnet-sdk-3.1.423-linux-arm64.tar.gz";
        sha512  = "ba4f82e939be43ed863f059f69cdfb80b6dfe7cf99638bd6e787b060c2c1c4934440b599c133f61e3a0995f73675ae5d927bb047597cdd6a15b9074891dfd62e";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/68bf0fe2-c2e9-4a57-b6fc-fcee862d6a92/6d13392c3596710426f91c6b46c6ff40/dotnet-sdk-3.1.423-osx-x64.tar.gz";
        sha512  = "89c23bd2a4b9d10af443d609194db33de4a5b7ed5f1328b705a87d68bd4a413a7e2a3e18a8a047aa7ce757224f4e81f3582bc91c1f4ffe074847656f56b26098";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

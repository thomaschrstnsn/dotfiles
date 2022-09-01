{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v2.2 (eol)
{
  sdk_2_2 = buildNetSdk {
    inherit icu;
    version = "2.2.207";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/022d9abf-35f0-4fd5-8d1c-86056df76e89/477f1ebb70f314054129a9f51e9ec8ec/dotnet-sdk-2.2.207-linux-x64.tar.gz";
        sha512  = "9d70b4a8a63b66da90544087199a0f681d135bf90d43ca53b12ea97cc600a768b0a3d2f824cfe27bd3228e058b060c63319cd86033be8b8d27925283f99de958";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/18738093-b024-4353-96c2-4e1d2285a5e4/5e86ebbca79e71486aa2b18af0214ae9/dotnet-sdk-2.2.207-linux-arm64.tar.gz";
        sha512  = "565fe5cbc2c388e54b3ee548d5b98e1fd85d920ceeeb5475a2bf2daa7f090fc925d8afef19b2b76973af439fbb749c6996711790287eafd588e4d916a016e84c";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5b8d25c1-85e1-4b18-8d96-b14115586319/78ff638656c3a90324e810f8dd157422/dotnet-sdk-2.2.207-osx-x64.tar.gz";
        sha512  = "d60d683851ba08a8f30acac8c635219223a6f11e1efe5ec7e64c4b1dca44f7e3d6122ecc0a4e97b8b57c2035e22be5e09f5f1642db6227bb8898654da057a7ae";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

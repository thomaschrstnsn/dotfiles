{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v6.0 (active)
{
  sdk_6_0 = buildNetSdk {
    inherit icu;
    version = "6.0.405";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c7f21771-9b09-4c81-883b-90dff8760c1e/fe992d38a94cc6f301c0236db3920c0a/dotnet-sdk-6.0.405-linux-x64.tar.gz";
        sha512  = "44e719c67dd06c73a8736ab63423d735850bc607adf4b8a9f4123945b13014f8144b4fb2c4cfe790d323106b7ce604388cc5d617bc153fd7820878b9187a2cd4";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c05dfb39-64d7-42cb-8caa-d669c0509c9b/d498099b33fd336d01e28c38515cb21d/dotnet-sdk-6.0.405-linux-arm64.tar.gz";
        sha512  = "6c31666a95817a7049bd47717c9cf9ab159e94e90987f46883e272dc6dee92fb0d890f4e590faca4458cd2b3943133fb2fa58c2fc175db98d4c6c531f6b2c3c3";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/3c785c12-6a6b-493c-929a-9a3f3dc568ad/6290551f01f9cc31039e70771d05aeec/dotnet-sdk-6.0.405-osx-x64.tar.gz";
        sha512  = "2a6050d72b3b453e8f9fbf73e40c1fc10b148c7cf6b5e6c30dbcd322567dec1450813b514361015629ec952718a61a5f3b8d67db9f0e7a32b149fbd874511c22";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9ef6ade4-4d92-4243-9e26-748a7c75c490/ef308e5e0bad95bc604fff5c5defd42a/dotnet-sdk-6.0.405-osx-arm64.tar.gz";
        sha512  = "fb1a66189cf54b14d1176ca9178673bef55aebcf16ce7616ba6b2d988b3152be7ad6d230d8369fd3a503f46d1f22d9074da8a48837118648821f7160f1c5533f";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

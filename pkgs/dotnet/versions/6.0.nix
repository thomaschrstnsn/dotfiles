{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v6.0 (lts)
{
  sdk_6_0 = buildNetSdk {
    inherit icu;
    version = "6.0.400";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/cd0d0a4d-2a6a-4d0d-b42e-dfd3b880e222/008a93f83aba6d1acf75ded3d2cfba24/dotnet-sdk-6.0.400-linux-x64.tar.gz";
        sha512  = "8decbba0a6b09501daede52cbb5a9ae9e5f31ade201918c03efcd1b4cc345ec934f88321704ec3beb1f90f2204934be7259c76f66d9204cbdd15933582602763";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/901f7928-5479-4d32-a9e5-ba66162ca0e4/d00b935ec4dc79a27f5bde00712ed3d7/dotnet-sdk-6.0.400-linux-arm64.tar.gz";
        sha512  = "a21010f9e0e091bf0a4df9dfc4ec9893c056c2b07b10be093ea392a4fa5c8a38bad9535f66e570b45dc25165b685199fb729434b845bcfb35f8b79cceb22c632";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f52fb2f4-a0a3-4094-9f75-add72fcbc21e/d46eda7abf39baf278c0b0b040c7b81d/dotnet-sdk-6.0.400-osx-x64.tar.gz";
        sha512  = "35b80347e31baefdbd42e7434ffa0df1069367a4f8deec8b4051a44658b3ed531832f0e92357887a2f5a27c6433304537c846cdd4793aac874bace82a899053e";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0e45597f-a72d-42fa-95c5-85a811a7a8b6/1d77d2eeb8c08815edd1a6e9e9dfda4a/dotnet-sdk-6.0.400-osx-arm64.tar.gz";
        sha512  = "c3b016bc558f42fba29a8aebcc04be7b3aa3b0290755b6ee2fea1f48f921da78b86cb31913c4b7e32c0421b45a617b551ba593f98f349fae43ea1faa38348412";
      };
    };
  };
}

{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v3.1 (maintenance)
{
  sdk_3_1 = buildNetSdk {
    inherit icu;
    version = "3.1.422";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4fd83694-c9ad-487f-bf26-ef80f3cbfd9e/6ca93b498019311e6f7732717c350811/dotnet-sdk-3.1.422-linux-x64.tar.gz";
        sha512  = "690759982b12cce7a06ed22b9311ec3b375b8de8600bd647c0257c866d2f9c99d7c9add4a506f4c6c37ef01db85c0f7862d9ae3de0d11e9bec60958bd1b3b72c";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fdf76122-e9d5-4f66-b96f-4dd0c64e5bea/d756ca70357442de960db145f9b4234d/dotnet-sdk-3.1.422-linux-arm64.tar.gz";
        sha512  = "3eb7e066568dfc0135f2b3229d0259db90e1920bb413f7e175c9583570146ad593b50ac39c77fb67dd3f460b4621137f277c3b66c44206767b1d28e27bf47deb";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/515fcb39-1e67-4cf5-908e-0e00f3cd76b2/6478e6b98726db240cb6b572f9eab97e/dotnet-sdk-3.1.422-osx-x64.tar.gz";
        sha512  = "9f919e42a692e048405b52cce8938fd4c40e7dcdf9c6c29eaa41940af7846cd2a678b5c43222d1cb988236917e47d85f37212bfe0c2dc6973cd5a8f2799838ff";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

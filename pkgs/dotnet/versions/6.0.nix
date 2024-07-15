{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.32";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/99f90118-96b4-4d06-97ad-d779715319f6/aecf393f9b9d362b66b93a47d90cfa8d/aspnetcore-runtime-6.0.32-linux-x64.tar.gz";
        sha512  = "1849c0073f12477b94357a1afb1cbd4ad67764263528b66037c19d554df41e681e4b41c0804b106319fe661d0bc3bae9e29e4913c0d0df33861cf6f32ebaac96";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/7b3ead1a-441d-42b9-ac91-1253ed8aee48/044d517eaff9f65e18e3e27f4d825d34/aspnetcore-runtime-6.0.32-linux-arm64.tar.gz";
        sha512  = "7b420354821f30809a6e8278f6e9c0654599d3e3b578b777da0f8e387612c20f28ddc49d5baac09627857297648a53ca847bc1237bc30275db5b661253f67523";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ff01df65-0536-46ad-bd67-95b72251e2cc/a9efc5c00994076c2635d70cac4f94bc/aspnetcore-runtime-6.0.32-osx-x64.tar.gz";
        sha512  = "7a91b051b6a48fff6838dc7565ccab11bb16ed0cddb1ce8bdb870d7b1a8978e544047541c2ff3b5b08272768e4dc8edd193cfb2acbd3a6e8cfd5b441dee24b47";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/747ff7b4-44cb-4f11-a052-00484643c9ca/60175b793e5b9b472fb53960ee3aabe3/aspnetcore-runtime-6.0.32-osx-arm64.tar.gz";
        sha512  = "63de1906b3217c8e42dc6da3c5d1dd0f02ec7c8c1f988e2b5df1ca4e2e9220d6ff306e5a1d8f2af1bbc7eecd00790799bf847097e9054f96cd460cb22d3e5ce0";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.32";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/37d9269f-d651-4248-beae-ccfbf4dc34fc/17809ba306015df6406cf4338b5cc576/dotnet-runtime-6.0.32-linux-x64.tar.gz";
        sha512  = "9babfe66f4a4261dd454f3220899af0a19532ab93575b581cec838f1c5f130d98b6fb1aaae5ee8e5b2e70deb55b619a0d55347f014ace72cb84b78d61faf0a59";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ae57a4e9-a6d3-4532-9061-72cfcbb90e70/89016f6466f00a8e707cd2f12fafe9e4/dotnet-runtime-6.0.32-linux-arm64.tar.gz";
        sha512  = "dd9807d0e8872956602241bdc06e33cc6d7cb5519bf7d7864e1671c8608adab28b539ab910778a5f2543e8cd06c9db64f8def044180f29167ac82bc36ee258e5";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/7ff71c2f-9fc9-402a-b88b-e85510530744/4fe521036c2d271ed8247fd5b761af1d/dotnet-runtime-6.0.32-osx-x64.tar.gz";
        sha512  = "d9e29d9b5fefd1b431135c6cf504dc16400920eaa1d7b67ec5b24d1ab672a9d573a6c55750abb116facd2b228ed07a73951b7feee1982d5b24ba3cd025b4e6d5";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/aea2980c-1104-4e20-b608-ff52a1295165/19c1f907bab296a31a1c084776bad885/dotnet-runtime-6.0.32-osx-arm64.tar.gz";
        sha512  = "cf9ec72bfb89124d12a359725689b5d4539ff6a8235fafada93d71b7e1c9d836592e6edecb2e1242a23298b0489050068322d2b9356b5d2e59f7dc519f2c5cfe";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.424";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e94bb674-1fb1-4966-b2f0-bc9055ea33fc/428b37dee8ffb641fd1e45b401b2994c/dotnet-sdk-6.0.424-linux-x64.tar.gz";
        sha512  = "e9823aa2ad261199f8289fde8721931c1e4d47357b4973b8c7d34c12abd440bb932064ac151b0e0d7b3d5b72a5dfe3f20d5dafa19e6f56f1a61ad54b7de5e584";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5f4b8e71-b03a-45cb-9a81-3cfcb51ef346/eb9509f0a061be1106689c1fbf5d5169/dotnet-sdk-6.0.424-linux-arm64.tar.gz";
        sha512  = "6a24dcad251016aa82ea11d3c665b250d5f86e7f8a82a6ec0f01d250e9cd671fd0746812757c023f28d4929248d326b2a5dc13ede8d5b5486671ea1452954aed";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/28142fce-3788-45fb-a84a-1b00493f02b2/bc8df50296819166baa09ad3d372dca2/dotnet-sdk-6.0.424-osx-x64.tar.gz";
        sha512  = "611a226f16d2dc6c5cfdac1911f116d159d65e1e0d4189afd8db8d88faecd92e32244e96c8d3cfa7d094a6d8ba086323b8d1d038bc0efffcd14795d197cf91a1";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9692d45e-74d3-49a6-b076-7f1248e92c92/62628ca1d882a0266afb8413a7fbf3ca/dotnet-sdk-6.0.424-osx-arm64.tar.gz";
        sha512  = "8de0b5aa92445a366807e3ba87d7b9de3b7dc035d96f7070f03197a6e6b78881d1dc279a619914140cd9025aa9084b35526d6db2c2db396cc07ebc398cbc6e71";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

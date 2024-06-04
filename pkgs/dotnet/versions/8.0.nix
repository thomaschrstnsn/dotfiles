{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v8.0 (active)
{
  aspnetcore_8_0 = buildAspNetCore {
    version = "8.0.6";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ce31d92b-b514-4f9c-843b-29c466871369/b332eba5641cbc6eed1e3a98480972d2/aspnetcore-runtime-8.0.6-linux-x64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/23defc47-8cd4-4ada-901b-9bb942e3cde9/9c386c008a3dccc23c70de3dbbbbb1a2/aspnetcore-runtime-composite-8.0.6-linux-x64.tar.gz";
        sha512  = "16cd54c431d80710a06037f8ea593e04764a80cbaad75e1db4225fbe3e7fce4c4d279f40757b9811e1c092436d2a1ca3be64c74cb190ebf78418a9865992ad12
bffc08fb0ec63251d06cf69c95844d19924b139f0417d1a79f729c856fda89610e03b3ed49844f7dd15401c447137f6daf5b26550269a2c0eb0bff253ab234ec";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ccdcbb70-a5e9-4753-b6e3-4461ce56a69d/240803fc1ffba38ab3603778c03e9b87/aspnetcore-runtime-8.0.6-linux-arm64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/933fe1c2-c361-4893-b187-06122ee95e52/20e0d984ff8be88ccdb6587c29fc8c3b/aspnetcore-runtime-composite-8.0.6-linux-arm64.tar.gz";
        sha512  = "9ed12847e404a0a4fdd8fca33a9a787c5ac2e6745d23821c7890f731f2f8f5682e7f9166b2764b13b612b08e091c71e13359b68acc11bcf990afdef1d42f6473
2ac853990b44bc1ebfa7ed31c599150f5c7f43b4a84ab7b7a96312ced78222dda93728d42b94b3be4acf763e6d95702b7d27186b51b56db25d39bb8bc745aeec";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ccd03400-c514-4956-9e9d-ad1bd67d1338/436b9590788dd3df98e73d4c5379c711/aspnetcore-runtime-8.0.6-osx-x64.tar.gz";
        sha512  = "61786ecd784b83eacfe4dd901bdd55474e52d9da85806b3d52184e8e35a3065b476e574c939f3af491a925bf7f04fdf376c53a25c103a187a7939f4736158297";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/b90758d2-834d-4fe7-b97f-e8294b68d07c/71d63df9474999f831811dd6989d9ba7/aspnetcore-runtime-8.0.6-osx-arm64.tar.gz";
        sha512  = "85d82e90182375ca21326e3d57be0dc5a39d7e64f1a4005950fe21c720f1d1e1615f64030c950fa7a49f6a104f029b9845648cebeb98d48d892aad3309c583c8";
      };
    };
  };

  runtime_8_0 = buildNetRuntime {
    version = "8.0.6";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/021c3de8-14d5-493f-92dc-2c8f8be76961/6ee3407acebf74631bfc01f14301afa6/dotnet-runtime-8.0.6-linux-x64.tar.gz";
        sha512  = "c0c5e93d4e68e2075c4c63336dc74246efb704ac9663411351efdefc4cc7da5a7750f44b8a23aebe959bb4308575bead443a41b2524ae03b29ac41929d27e0e0";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0039e2c5-d78d-45fb-94c0-e258ff0335fe/c3bff45767f679bbab149398e9ee2c6b/dotnet-runtime-8.0.6-linux-arm64.tar.gz";
        sha512  = "428c5a81938273c5e63b04858dbf2f4e82c9bcfa3bd33f954081238be2fb52aadce99296698eabac72e4be55c61e6c1ff06d2d8d1fd5d6a2d0c7a2917cd50739";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/20271d05-67e0-4356-87a9-0ce5102b5007/b7c91c6470e1c2ffbb493a35dd6883c0/dotnet-runtime-8.0.6-osx-x64.tar.gz";
        sha512  = "44c0ad9fc613975fa0c12b12b91ff8cd8ba0be5e8ed59510e7a5ab22e55267a468b321ce34515daf070ffc8d557c09d7ea3ed3c3407887f706553b5d378e3232";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6f090da0-5f55-44f1-ac17-9bd001b33d66/eae314b23ab350b375e794e136a2ca9e/dotnet-runtime-8.0.6-osx-arm64.tar.gz";
        sha512  = "21ae6420914e45be9fe17bfb0c89948eead27756dedb13fc2c6b9b08d78aee80daa2b8cda358268c819f00ba7ca33ed75e21bed387045b3a62160fea159eaa3c";
      };
    };
  };

  sdk_8_0 = buildNetSdk {
    version = "8.0.301";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/86497c4f-3dc8-4ee7-9f6a-9e0464059427/293d074c28bbfd9410f4db8e021fa290/dotnet-sdk-8.0.301-linux-x64.tar.gz";
        sha512  = "6e2e1ad5fe3f00e6974ad3eac9c5b74cd09521f19e06eb9aff45a44d6c55e4a2c1cd489364735215d2ea53cec2a7d45892a5ede344a8421be9ad15872c3496a2";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/cd9decc0-f3ef-46d6-b7d1-348b757781ad/9ad92a8f4b805feb3d017731e78eca15/dotnet-sdk-8.0.301-linux-arm64.tar.gz";
        sha512  = "cb904a625d5e4ef4db995225d6705b84201dc7d7d09a0b1669baccc86e05419472719025036dd78983b21850f7663d159ae41926364d1d3ca0eab62862f75d29";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6ef47a54-b1c6-4000-8df4-486f64464c2b/ae87b597b19312fa9f73b9f2f8c687bd/dotnet-sdk-8.0.301-osx-x64.tar.gz";
        sha512  = "5d91fbc584f32f4d48dee303c7eb16b38b2e2fab9549bd54293bac28508a6d53f93782ff102266010f8cd8c15c6436a807a7e6efede2e1051fe206957ba73071";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c503e53c-0567-4604-b7a8-1d6e7a1357f5/53e78f56b01147a092c0cc273b443550/dotnet-sdk-8.0.301-osx-arm64.tar.gz";
        sha512  = "8d56980b6a6ffd78618a6e9833126d7e67052ca6041bd5f167a32e277aac7094a5cd37b9e7e145d5c9b74da95561535189a077d074ddb0fe710a76c2a2c9b1eb";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

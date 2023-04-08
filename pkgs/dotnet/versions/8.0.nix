{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v8.0 (preview)
{
  aspnetcore_8_0 = buildAspNetCore {
    version = "8.0.0-preview.2.23153.2";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/930d8abc-009c-47c8-97cc-4c61ca7a74ef/7a116b9554c6db0d84f53937f89d5240/aspnetcore-runtime-8.0.0-preview.2.23153.2-linux-x64.tar.gz";
        sha512  = "1752ce53c8dbc59b3a321da7d44862410bdf29153124099106ec7397ab1fc650aa902849e198da38e5360f7ea5cd3e3f12cf78a9ec8121b666bf1db2080fd7fc";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/87c69e56-17b4-4346-995d-14242e2ec5bb/b656ba5e42d9d96ba065a4d0f971590b/aspnetcore-runtime-8.0.0-preview.2.23153.2-linux-arm64.tar.gz";
        sha512  = "4109b7841aa022b777b0f2ec4191ba0773736b5b4411402a1de6d14a63d273a9114e897c7ea38d3ca0bb48de20b165712aba838a6beacf1c31885f1fce0bb2a3";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8bf4989d-9696-45f8-af31-afd2a7fc5ca9/0892caa5dcc0ee2b342d85963610fe15/aspnetcore-runtime-8.0.0-preview.2.23153.2-osx-x64.tar.gz";
        sha512  = "e711051b2fc7593ce099b200cbe92e56a09e795afefc983f4e3acbbf90019e0b209c5c2a44ae3e3d8228a8c7fbdbaa5e3463ae4dfd7017a6d265537ade01d7f4";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/af525c46-4f32-4fb6-9435-522cb5f6b8e5/2323948790b195eebccfa5121d434e74/aspnetcore-runtime-8.0.0-preview.2.23153.2-osx-arm64.tar.gz";
        sha512  = "62358024b8960412f9e457e2dba14f65e03a50557bd6cf23a6bd77de87539d6b93dec55b375375f1ae7ca88de16118d3dca9d72f0a82a31fb3dab0c8e33bbf08";
      };
    };
  };

  runtime_8_0 = buildNetRuntime {
    version = "8.0.0-preview.2.23128.3";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f74940ab-c6c8-4464-8a4d-a1149a9dc965/c774b22355f65c13101937cbd2a79071/dotnet-runtime-8.0.0-preview.2.23128.3-linux-x64.tar.gz";
        sha512  = "b24bbea7fd0f1d5ca57544ccc690c05496667f30b0804b93a8baaea5e0d201bc471357e0ffac8a4fa5c399d3827942c7f6beb0e3a022e8d0d8cc7ba0ae86a379";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/31b60621-dcaf-4b89-83c6-cd9cc5657350/6a5b181b84409a029d80acc94c0387b5/dotnet-runtime-8.0.0-preview.2.23128.3-linux-arm64.tar.gz";
        sha512  = "48a80c18754e46a12fb04e280cb23e8f9238603aeb0a91125a583eac27a7abb1b20d08b3121444085e4d2034380849dcda88ed69ecc5c4af7e8e3c38a3392921";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/79a747b1-a7b8-432f-a641-fdc528f4d885/242cab0619683336965c964038e57ff7/dotnet-runtime-8.0.0-preview.2.23128.3-osx-x64.tar.gz";
        sha512  = "eb5f6eac1211e5c0398882d4f5e1859b5e2439e0564da4fdd4c8b3a4a60d360a4b9b48c06bc048badcc2d6a2b539ee740f85ae6e7ab03bed40ba9574655fe044";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6651d249-9e3a-4726-9733-76307787c213/445ad516907a2939a3da383501e51cfe/dotnet-runtime-8.0.0-preview.2.23128.3-osx-arm64.tar.gz";
        sha512  = "d6dc11b7e5cea5e96e45a401027a2f3e498e41658b3a1862cddec009a96eea83cb929338e402960e150fb3f77da582f1416d0f5231d6beadfd32a443ad68e9da";
      };
    };
  };

  sdk_8_0 = buildNetSdk {
    version = "8.0.100-preview.2.23157.25";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a042ab5b-f160-4621-ac14-77be759167d7/373e6e8ae9381ffc1ba853bb6542d55c/dotnet-sdk-8.0.100-preview.2.23157.25-linux-x64.tar.gz";
        sha512  = "97302c3600af7787fb136b226ca7e2a0a22241aa93dcffc70010b475bf6f8c4ff74a363d94949e1b64a91032b57a58a7065d7c6b2177696d8e78504ef4f1280f";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5ca09c3e-e6c0-4ea2-bc1c-371cc4d0b79a/f05e4e38788662b2e226bf75569e42aa/dotnet-sdk-8.0.100-preview.2.23157.25-linux-arm64.tar.gz";
        sha512  = "440919e2c0d3e0bfb387e2d0539b39045c6581a41f0237c88566d3642ab2c5e4a8e540f3d9d514997bb4a17b19c64a46b80f38af5f66705da1349373f87448ea";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6a390a1a-2d50-4ea3-a5f7-0a945b30a436/1968bbba00d7c4a3d2f0b8d13002d77e/dotnet-sdk-8.0.100-preview.2.23157.25-osx-x64.tar.gz";
        sha512  = "f3c4bd87d15a0593895121993326adef55641b59682ef52f6ff5fd44505468784590cf5fada9ea531377389ee47202db89de0520cdbbd497f85f5717fb74879b";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/62c49e14-4f0a-4698-aa08-8d77d383fa8f/909bb059d035324ddc2e8a8fdb77a01e/dotnet-sdk-8.0.100-preview.2.23157.25-osx-arm64.tar.gz";
        sha512  = "3b5c169180538a13c3199de0df096a2a84f58d2b55bc0dc94be374a015a231c035e57fa62e160e9c5595c6fcf92926ae9c577c6d62cf17803d931e5e90b5e694";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

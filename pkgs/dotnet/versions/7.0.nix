{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v7.0 (eol)
{
  aspnetcore_7_0 = buildAspNetCore {
    version = "7.0.19";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d3d6c11a-a7d6-4be4-8b2b-11154b846100/69bd5fbe2621600e84bb191d0b13abdd/aspnetcore-runtime-7.0.19-linux-x64.tar.gz";
        sha512  = "569fcc25f0c32df3b28c4569bbeabb6c20afc8865088f14a405d3847bbfd159cf291d2dc4810140b8f436f06c95ebb09214ac837b5ade6bd8121e9c0204eb217";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/78d9729a-9f05-49a6-81b7-b041452a2828/73214343fb60deddb7faf355ecbbaca3/aspnetcore-runtime-7.0.19-linux-arm64.tar.gz";
        sha512  = "c71e6a756bdac7f68289fb6c67fcb8c347586e421cbf4345fb510686ff5948e25898759dc7ab30904ac07a7d595508e59d66b5b6dc88d30b54c141c82bd590cf";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e2bed645-39cb-4ea7-ba7c-503741d8d9e6/07bc37ec71cfe01a4187d94275580b3c/aspnetcore-runtime-7.0.19-osx-x64.tar.gz";
        sha512  = "5f16d0cea6b637ad9835dabf23b37f47d8fe92fbd4cfb1ac046fb607beb380255759f14f3e80f9a49c3545afc47000c770394d4dacc5b7444ab0b6d87a5336b5";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/879c8cbe-37bd-4fc9-b8db-857a3fe09144/231cf7ae2bca959750144d08ad08d057/aspnetcore-runtime-7.0.19-osx-arm64.tar.gz";
        sha512  = "10fdc9868efdd8cf25dbe10843ea17075747cc1bee52e495af7e1858ff556dac2802bfcc85fd474527f142672b45e7a1c5b63a927529036923671f6cb9092431";
      };
    };
  };

  runtime_7_0 = buildNetRuntime {
    version = "7.0.19";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/09ab2389-5bab-4d45-9a91-a56ff322e83c/2f8192a98b6887c7f12b0d2dc4a06247/dotnet-runtime-7.0.19-linux-x64.tar.gz";
        sha512  = "4e556c1437a58d2325e3eeb5a5c4b718599dff206af957a80490ef2945b1a2f5114d25b808b4c9ea233cc4eb2e5ce40932bb249e198319e97f3b5cc443612e6f";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/81616b49-6c82-4778-884d-caeca4c195a9/51a0a0bcdd17fdb77be7f1c5db52165e/dotnet-runtime-7.0.19-linux-arm64.tar.gz";
        sha512  = "fde0a0190c77cd361722d2ce449b207b6a26c7f6462dcc9a2debfa1b0e670f7df0b538758ea5eb865f156df17a98722ed7e8f7a2bfceb0a486d1b06a2d436240";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/92c2b6d8-783f-4a48-8575-e001296d4a54/c11d13f994d5016fc13d5c9a81e394f0/dotnet-runtime-7.0.19-osx-x64.tar.gz";
        sha512  = "005828f1138cfce1f04741a478595186a1098185747ed0872099d7541d2bed16416f36d1214f6289f6ed1d3543e119733e4bba6dddf42db43150bc7bf2e980df";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4b8da067-3b82-4636-8e0d-18583857e64b/fba7ceea0e014535a695ceb9259886c6/dotnet-runtime-7.0.19-osx-arm64.tar.gz";
        sha512  = "394f0f068b1dcd8f116c41391baccb46fd1112578281b0d11edd6dc194b767850c8a2bb9e2bc041b1e872872afb130fa10f7c98fbac988dd80c0d788a0f23e7f";
      };
    };
  };

  sdk_7_0 = buildNetSdk {
    version = "7.0.409";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/03e24745-90c7-4661-8ffe-e5a857b6e6a3/99038e4e48e403a17bcbe509bfe8d6b8/dotnet-sdk-7.0.409-linux-x64.tar.gz";
        sha512  = "0b67d04621d7c2a1856fdb0cf6e081090b4e1df1075d2f881fb33655422f2f59f63f8324559dc207510485f77781cc20c7a407e3c04dc0b53246987164427671";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f065c679-7039-4968-9a2f-dda7cda72f5f/702eb11e596f498a1cb23b636e1d83be/dotnet-sdk-7.0.409-linux-arm64.tar.gz";
        sha512  = "ebf98115e3ef9a5388394443b8cec8aa104c2468fbcb6c964661115665645326abb0bce42786a98eef4ebffe42dedd36de8608e15538d191e934dc83fcd8b2f5";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/feee7b85-ddb2-4ff5-8927-5656ea1e0a6f/ecdfb330298d11e0d49c3b595ddea452/dotnet-sdk-7.0.409-osx-x64.tar.gz";
        sha512  = "70efa550d6d78e17db0368e8500ddfd9a6343707e009247d00062613e8052463d3d83779af619128233e78a29f5b5a5f71f0eaba740c3c3f74be0c76145c892b";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0025e3a3-0221-493e-90cf-a5baaedc3cfa/716e07c6342d6625dd9a04f632ca8d50/dotnet-sdk-7.0.409-osx-arm64.tar.gz";
        sha512  = "bf234cc2c6e90abb891cbefc3eed35e63fae07d312f01193d8890dce03edbaa3fe5a095cc695bb03ef35fcfd1c2e45e7b9d54c3b483761d7b1653a019c55b53f";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

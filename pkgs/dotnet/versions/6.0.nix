{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.30";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/03d1bc71-2ad1-41b4-aa2f-9e4ef6d5c6ed/29b655655d626c590cb216e0c30bccb3/aspnetcore-runtime-6.0.30-linux-x64.tar.gz";
        sha512  = "757d017db28b8e34c4b242c082aa51eb85bce8fca16af37a0beabedb271c9bd13e1631868faa131745d7784db48974567f82275da09041ba434dcb7abe821a2d";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a4c8e994-c595-4698-8cfc-cf3ac166bbbf/9e6b514da011de5191d148d95601a7ec/aspnetcore-runtime-6.0.30-linux-arm64.tar.gz";
        sha512  = "de0921903ba55e21195107b126e271457550543fd6a9698ab3c2b1e2b95f7fe2d6fb2f067e08ed10c9e56940c247733dd9a2f9775e7993e033a945899461e130";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/15ab71c2-9230-4afb-87c5-36328af745ed/b859c077ed4d8c00985a2ee87009b6f1/aspnetcore-runtime-6.0.30-osx-x64.tar.gz";
        sha512  = "0a0c4c9255ed29db1c1911fa0fc6c8a9083f777c04a3939b2087d80bba21fbd864e6c92c62aa566a930a2b30024b1fdbfdcf34d034e2734c0a9b3d45f7c63445";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0a61c065-2196-4a9f-a34a-9517b3ec9336/538e1624926840a66ef6963f57d44aa0/aspnetcore-runtime-6.0.30-osx-arm64.tar.gz";
        sha512  = "a74d44c399e06c9ce19ec10d4be53444bf18d981fe7ede62a69efc24a5af5898d4ee63542ffbedc3b906cf1ac3f7101ecdb69e45dc0fbb1336bf151940fc2204";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.30";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a80ab89d-9f64-47b9-bba5-907a4cdaf457/c5714a6e605ef86293a5145d8ea72f39/dotnet-runtime-6.0.30-linux-x64.tar.gz";
        sha512  = "b43200ec3a8c74475f396becd21d22c6a78a6713585837707c2a84bbb869c7e551a05c4c1c1cdba8083baebdd09bc356de5d5a833b8bc84b83421d3ecfac71ca";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/27a21bdd-cad5-4f5a-b7a3-86942632a745/3d7aba7c0cfe0c28342a8f83b65e72b9/dotnet-runtime-6.0.30-linux-arm64.tar.gz";
        sha512  = "75fa6de07e5d8e5485af910de522c1d0afed0532008ded1e80ec3f576c9a78c6e5759dd4d1331159263c02121a4d8f1e532f0533c11524c2d782cf861be13c09";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/aee516fe-b6d8-40db-b284-1a287f7cd5ce/c217b7cdbcac883886169b82bcc2b7d8/dotnet-runtime-6.0.30-osx-x64.tar.gz";
        sha512  = "8cffba5feca56bf11b38318564c45ae18a58ec48223963ee46105f71bc07661457e562d51ea0e8b626eb69b7635565244a5cd1575b6fbac52b776145c533e784";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e78e6379-e47a-4e24-ac6b-1c3182f1d664/b8f47b2f04b15c78ac24a8bc88000131/dotnet-runtime-6.0.30-osx-arm64.tar.gz";
        sha512  = "b33a38f4e41455cd88e23f6c0fa76797e05af25bcd94d500557fdd5ce10071ac16789ddef98ec9abef113f2aa487fc7d5c22f329b8a7941a79d7768ca176975d";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.422";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/316ad9ae-22cb-478b-b51e-47667f1e7027/7a13422c0951e9235b7692c610b83442/dotnet-sdk-6.0.422-linux-x64.tar.gz";
        sha512  = "e0e6ea234a5aef29c2571784c22396115db292fae8f859f4642f80f873807140bb7bbc009be568e8e34288b46b2e3e7732115b5f02bbc8ca0aa723e183bc084a";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9f8f2c2c-e531-4a5d-b7ed-1e7e4b8bbc29/12e87ade15ce29558b40099d6c152b10/dotnet-sdk-6.0.422-linux-arm64.tar.gz";
        sha512  = "c03c3708061f266a3d7fb5bf2240f5bdd00be4d877dc3dc62b95a857f2ad62c80dd4c54f5257737ef7bad3cb458685d7f2bcfe71c3562075ac3aed660df8ae41";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/818b0c97-95cc-4da8-b5af-05f6854c5e89/200ee246643a1d6a0436ad967ae705f1/dotnet-sdk-6.0.422-osx-x64.tar.gz";
        sha512  = "a301982e64a18cf06577463fc3e2e179c06a31597b1b32127b1196dba755bcc3323edb618f6000c9f4f9ed902c671377a459e9ac90da2c761744fc1d57e220cf";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2f0c0bae-a26c-44c1-bd9e-9fcd42548066/c88dc835e8ac824d992696122c10d959/dotnet-sdk-6.0.422-osx-arm64.tar.gz";
        sha512  = "7bb885b605f51cffcb235a6bb6f0eccef7a211e67480fa6243b0cb8899dfd60c4c0501579c0c1dc7fb267aea5db5a6d35cf9e2a35903772797a66360fa171b3b";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

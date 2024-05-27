{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v8.0 (active)
{
  aspnetcore_8_0 = buildAspNetCore {
    version = "8.0.5";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ccccfeb7-0af4-4713-b4f1-cf49b5c8bd6c/5b04c0188dfcf78b70da78ae3bd7f3ab/aspnetcore-runtime-8.0.5-linux-x64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/ce76101f-0ea1-45ee-b38b-1dfa0ffc60e1/8134663bd2d175725ad37733150c1901/aspnetcore-runtime-composite-8.0.5-linux-x64.tar.gz";
        sha512  = "ffe6a534ed7dffe031e7d687b153f09a743792fad6ddcdf70fcbdbe4564462d5db71a8c9eb52036b817192386ef6a8fc574d995e0cdf572226302e797a6581c4
5c22f047cce57cea17e189af3305e6b0f8b1aeaff59b471907f99a8e936b9442755edfae015b2b3ca635ee160a8a33cb71cea7e71391a26d04866dbf64339bb6";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/208a57a8-fcc0-4801-a337-79095304d2af/d1ffa79af24735af4bd748229778c1a9/aspnetcore-runtime-8.0.5-linux-arm64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/ef17fbc9-1bac-4346-b04b-db0114e2714f/74c4636b4fb78509d65be904c9c1e71e/aspnetcore-runtime-composite-8.0.5-linux-arm64.tar.gz";
        sha512  = "54ad859a3307a4ccce6aa794df20dab3fc38cb4a8fc9f1c2cb41636d6d19fed1e82f88a0099bdc9f30e08c919ae5653da828ae54b0299291dafcc755575f02db
e5ea9700bf8b82ec11f9d8a6d6057534375e902b462c417ef7f2072b9865d9d561cc6c6d90859e3196de9862d17970cb47ae6abc1a96ec39e4345792d9551ada";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/77cd03cb-5575-48c9-8714-6498ee88694b/8bfba2913a4db23e3dffdff779fb7866/aspnetcore-runtime-8.0.5-osx-x64.tar.gz";
        sha512  = "d214a8b6a60547acb1a7f879e7a82348585b699f714b73b168918ebc60ee580ca5ff973f64e7738063f79dd04f0807bef0d73e90ce42c3b4464b87b768ccd789";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c264657c-7a93-4ba5-b6e0-91bf41341e1e/90fb45ed7d2f92c374899b1c7a5254b2/aspnetcore-runtime-8.0.5-osx-arm64.tar.gz";
        sha512  = "b1a47d2ae3b528f5c32b57e3a03b46d12a14126b9768f9dd5dd979d49dc6543c6aafe55684eae3890ffe6b867aa664805b920ae1514f67cc841b882d5da7c091";
      };
    };
  };

  runtime_8_0 = buildNetRuntime {
    version = "8.0.5";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/baeb5da3-4b77-465b-8816-b29f0bc3e1a9/b04b17a2aae79e5f5635a3ceffbd4645/dotnet-runtime-8.0.5-linux-x64.tar.gz";
        sha512  = "3efff49feb2e11cb5ec08dcee4e1e8ad92a4d2516b721a98b55ef2ada231cad0c91fd20b71ab5e340047fc837bd02d143449dd32f4f95288f6f659fa6c790eaa";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/00ca4d7a-e529-4384-8ad4-acb8237d540f/a7df4c26e3c0e1dcf8e17d2abb79aad5/dotnet-runtime-8.0.5-linux-arm64.tar.gz";
        sha512  = "cd6c0ac051c3a8b6f3452a5a93600e664e30b9ba14c33948fbbfc21482fe55a8b16268035dd0725c85189d18c83860ea7a7bc96c87d6a4ee6a6083130c5586c3";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0dabe69f-fa99-4b53-96d1-9f9791bb0b6b/f72acbfd3b0e60528d9494b43bcf21ca/dotnet-runtime-8.0.5-osx-x64.tar.gz";
        sha512  = "29a8be6dd738d634cc33857dc1f1f6cc2c263177d78eb1c4585c96b5bf568f8f2689f1a30eec728ccb96a2d005049936abbfd44daca1962caf4f6d53325ba42f";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fac90ccb-5864-4d4a-a116-67387aaee61e/df82eea80efffad3c9ec8b0522847e68/dotnet-runtime-8.0.5-osx-arm64.tar.gz";
        sha512  = "5401135b8871d85ca6f774958e6a644ef2bf85a88d2358f15c3bdc928b21a700be428efede677d83640085461d000e55a28bfbacdc9f01af0334a6e8b257efbd";
      };
    };
  };

  sdk_8_0 = buildNetSdk {
    version = "8.0.300";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4a252cd9-d7b7-41bf-a7f0-b2b10b45c068/1aff08f401d0e3980ac29ccba44efb29/dotnet-sdk-8.0.300-linux-x64.tar.gz";
        sha512  = "6ba966801ad3869275469b0f7ee7af0b88b659d018a37b241962335bd95ef6e55cb6741ab77d96a93c68174d30d0c270b48b3cda21b493270b0d6038ee3fe79e";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/54e5bb2e-bdd6-496d-8aba-4ed14658ee91/34fd7327eadad7611bded51dcda44c35/dotnet-sdk-8.0.300-linux-arm64.tar.gz";
        sha512  = "b38d34afe6d92f63a0e5b6fc37c88fbb5a1c73fba7d8df41d25432b64b2fbc31017198a02209b3d4343d384bc352834b9ee68306307a3f0fe486591dd2f70efd";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e05a3055-c987-4127-a315-51d6b982fd67/fbda30d8e461b2c5098f3c405378b559/dotnet-sdk-8.0.300-osx-x64.tar.gz";
        sha512  = "12ed6044dad31c65d6894d7e1cf861a6c330c23761fed90ca2fe0c7d2700433fb8b8541c35bb235b044762f5fd33496cd6e92dbd70deeeb7b9e59423d9d49f5e";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4d7af168-9a20-40a3-8744-b2f1c10c0227/3d6d8d16545d6c05125c51ef8142296f/dotnet-sdk-8.0.300-osx-arm64.tar.gz";
        sha512  = "98a9b56b2795bf6faa848062ed34d917b187eda220db50c8e73de1bfa37244dd68d8c3cbc598b5fc5be4620a2b92724f95d7c13299f8b873fdefe880890a1bbb";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

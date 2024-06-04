{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v7.0 (eol)
{
  aspnetcore_7_0 = buildAspNetCore {
    version = "7.0.20";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/09e67261-215a-4003-bcf8-f90d67dcd02b/b32cf12a5c10b1f74e21c8cb03880891/aspnetcore-runtime-7.0.20-linux-x64.tar.gz";
        sha512  = "62ed9743972043a72e48d5aa2f7fdf3483cf684a32b051315004d1c778e9712bf66e5e7a97a5a53993fa8e92daf5bacaf2cdb3eae44bb9a9e25532b9a80f4f70";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/ae3027ce-cadf-4510-a1aa-125958cf0432/c3d958ba80ec21e9d75ca5e8f43ec2d3/aspnetcore-runtime-7.0.20-linux-arm64.tar.gz";
        sha512  = "dfb1c1bef4d826defd3d995599a5c03e1bf1a64c65d98b675d6c05dbb7380d98233953e68d53fc5ebec60ad4ef75417073fb1fb3256a0176bb964f0e01161f6c";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/65fff3f3-1b87-42aa-b1f9-04e7e318c1af/4bfbb002455b9a037e75791e99a18c19/aspnetcore-runtime-7.0.20-osx-x64.tar.gz";
        sha512  = "00677819450d14d9adc2b65f25b9a069bc2b43f72e4db651e77fe0e48320be8eb7c555277281de968e75d0fb19bef960d4dcb27161b8c57bce076ee18bb5ca98";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2833b957-8fb7-45fa-bf85-4960260ae344/fa4678e8c3ceba67771b5195a2343049/aspnetcore-runtime-7.0.20-osx-arm64.tar.gz";
        sha512  = "7de161ea45faef7693d78ca44b585ab73fc183232d3f8d229fde3d05d696818d8d6402ac7ac86ce239a0a6cdae8fc2eafbb445e99443d0c7a4aab3781df35be6";
      };
    };
  };

  runtime_7_0 = buildNetRuntime {
    version = "7.0.20";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2c5981ff-0f0c-47ab-bff4-0ea4919b395b/cbfdfa7f35d133b0bdef87fa3830bfa0/dotnet-runtime-7.0.20-linux-x64.tar.gz";
        sha512  = "87855297338555a7b577d7e314e5dbf2c2350f8c867a489cd1e535634bad5c123a1871464d37fc9421837ff5d426c2eadecbe0f60bbf3fd32bc2461f47790a40";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/af6e12de-a63c-449f-b35b-b72ec6ee3da5/ae129eca3d734117d14cd5965dca93a3/dotnet-runtime-7.0.20-linux-arm64.tar.gz";
        sha512  = "c245125ee2708252119a1544556e1aa9e00aa18b2303de69877da10c6c17e3f25024b749ca93b53be76ee0e8e4a75d403f7019b8bc2e50ed1278f656cb2f7e06";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/cbade9d9-be1e-46c0-9f90-13ba882965dc/31c86e8f4beaf0e5ad9ad35a408be7de/dotnet-runtime-7.0.20-osx-x64.tar.gz";
        sha512  = "acdcde92f2f2e43584ee59be447f778f4a152c308975c7bdc5c2372b5bbd3092eb9d2233aec3b82756ba1e352a0877ffc17e4c8cfb20a9de91ca6db54d79b591";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/50dbf5c1-942d-4fd8-b646-1f024326ec1c/5fb99e9dae294298a8131757b3ea829e/dotnet-runtime-7.0.20-osx-arm64.tar.gz";
        sha512  = "af1cb62e29c69648ebe334e651c2703cd5e87fa0bb28c670bacb3b3dd1608aeae35ae53402c5eb4ed8bf34abd831a08ccb5ef84e5ec70617d9f8d9969fe7b8fa";
      };
    };
  };

  sdk_7_0 = buildNetSdk {
    version = "7.0.410";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0ddc1522-2361-4394-97e9-52318bf51951/c5aef30601a86810f1f8ea89d42c26a0/dotnet-sdk-7.0.410-linux-x64.tar.gz";
        sha512  = "20b8e02979328e4c4a14493f7791ed419aabd0175233db80cd60e2c004b829b3e8301281ea86b27ba818372473accf5a6d553e5354c54917c8e84d25f5855caa";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/3e408891-74af-4ccb-9ce8-895f6806a97d/3a589bbf6e264059544cef47be672540/dotnet-sdk-7.0.410-linux-arm64.tar.gz";
        sha512  = "2db6a3b9a532d2f59a2b459e634206913a9585c821f3f578a421e3bae346a92dd9b85b76ebde343ca3057275f7ec4d0bca71cbb7f2badb6dcdb516244e84da46";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fc8614cd-f333-4adb-815a-9bbd07e02b16/0ccf5e50cf8fa5c600716395e240aff1/dotnet-sdk-7.0.410-osx-x64.tar.gz";
        sha512  = "782e15c19ce20aa8333566f23c2d3cdb8e89c7626de6330ddf670c4426e30cc854e44ff3341578622aecf210fa66ddcb63a7d2ad629ed92cb5582ab670f953d2";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bfba06ea-d182-4a12-8066-fd78413e6cc3/f7940d1e8d8ae641a3a3d65b6bfa1071/dotnet-sdk-7.0.410-osx-arm64.tar.gz";
        sha512  = "c0ef1914f2b298504433bca9cdab02dcf324421ece39657b66523f13b7a7166e726783673a602fb462f3db5c53f59a89381b918e7658d49a57763b43cf75cedc";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v7.0 (active)
{
  aspnetcore_7_0 = buildAspNetCore {
    version = "7.0.4";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f2e33ca2-e597-4d7c-b34d-60e47b5fe2fc/a22feac281b4bf63c8b5195a30e6cce1/aspnetcore-runtime-7.0.4-linux-x64.tar.gz";
        sha512  = "b0d2896928c003abf79c539c1c6be13ad560a34d8fdbe9438d916a977aa59e648d0737b57aafb25fda1c3de7c95997eccbea28ae04e4131ebfcd18c36940bcb4";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/639aae36-b8fe-4bb7-86d7-0216554b6183/3b5caffe27bb78bbb10aff729d65ae03/aspnetcore-runtime-7.0.4-linux-arm64.tar.gz";
        sha512  = "5e149ccdd003dfc4413927f23b07b2f27ce915c63146e514b2f88446bd44f64df51755644b56c316b0a1388c873404fc1d39b24a0bf8066f09fc37d6f32cc03f";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/eb055f27-b58f-47db-b291-91a2700396a4/7b313614b3ba0cd2f9e57b288c82f0b7/aspnetcore-runtime-7.0.4-osx-x64.tar.gz";
        sha512  = "36a573380caeac220cd7d4bb1a008f440f37eee21be4c0156b95974739264ed5b3ae1776462a5dee286f387719d3241b57141d2604463d8367038bc718d9178f";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d70d5370-7f1c-4fd9-88cb-504569112323/32a23f276392a1fb04f2f3cdd35f961b/aspnetcore-runtime-7.0.4-osx-arm64.tar.gz";
        sha512  = "07771022448fbda4248ac153d401c11ff0c9cd33ffd9a6c480e7a8618b802e7e33152673557dd92a5467199c275ff8b0fd007e132ed650d594759743d3da7f8d";
      };
    };
  };

  runtime_7_0 = buildNetRuntime {
    version = "7.0.4";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/08c89e27-b593-438e-8303-af765b90e5da/28b1b06748b86a694ac4ddf43d546a32/dotnet-runtime-7.0.4-linux-x64.tar.gz";
        sha512  = "23e6aa3714410d794bd25af781046757003e3326cb8b13dc256649011815038893718b44ec2162767c7da76f1e16b170656d5726e7c01e99b9577682ecfe281e";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/47a77eda-2e32-4106-bc84-375b873a9839/c6d88de403b103248f67f429507ea269/dotnet-runtime-7.0.4-linux-arm64.tar.gz";
        sha512  = "2726dc5a0b7b97c0e1ad22990b31133a1af46cb62d625778a9864a0047462d12ef705eebe08e73514bd10af50c06b5c9714df070f29c5203cf1c2587645d84ce";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e4dd643a-16b8-4f1e-ba38-cdbe32cc24df/67b307accc4abbbc2238310d6ea3c516/dotnet-runtime-7.0.4-osx-x64.tar.gz";
        sha512  = "3042f6c711da88a669c92101ad3f6bd008e475230d68802f52b2748a8db6eecfd2af40665669a3d846910bcaf63ea27277f6a33bb76ec6fb3e256320e2f6dbf0";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bf2d81d2-d793-43c6-af0f-763a48e1fdea/0457d06cc4e7dea7fff49e944691c72e/dotnet-runtime-7.0.4-osx-arm64.tar.gz";
        sha512  = "4451ef94395eba2dfdc1af4b43f619d58fdfdd444fb122ddf1666d6f9002d792a52c52f64940433797920fde680b999095872edc1233c5721994c2092978cc85";
      };
    };
  };

  sdk_7_0 = buildNetSdk {
    version = "7.0.202";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bda88810-e1a6-4cf0-8139-7fd7fe7b2c7a/7a9ffa3e12e5f1c3d8b640e326c1eb14/dotnet-sdk-7.0.202-linux-x64.tar.gz";
        sha512  = "f415a8e6c078421759a963aa0b232c092ecf2f0a8e014ba72092390aac792ed35e8f3c822b2ce91ed636cdee9342bba2b89fb4fdfd2d28dbb0ac856d828cb29f";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c1fd11b0-186a-4aa1-a578-bb1b6613886e/b67e1c9d6d90b1c99b23935273921fa1/dotnet-sdk-7.0.202-linux-arm64.tar.gz";
        sha512  = "6f03de4ef1d0f67bcf8f794beea1a1497c9b1d31c484675382ad63a686ad3047ba2e12b2739ef2bf70c12e61a462ee8abd87e96a7c48200dceab92094144b332";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d3fe9043-0ff4-4584-aacf-1ad41c47407b/7b84ed341359488cd0de21de1b4df6d0/dotnet-sdk-7.0.202-osx-x64.tar.gz";
        sha512  = "3e99224ecb4a6ad06b96daf7017a749dfab1a9059daed1304a35acab9eb4fcb0a97f8e1b4d8c3074536b9dd8dd98dc89db3603057ae59a59e01d459bf26f4fcc";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4402413a-ef81-4732-a0c0-38f11694b226/e205b8bf48d95902a6dbe1c3cccca272/dotnet-sdk-7.0.202-osx-arm64.tar.gz";
        sha512  = "9f5cc528d5d229cf2f63384afa52176f049c8d9e0d9d9be0ccb1a169be78a65a61dba7a4e74357685d434447b3d2697c062e9f240a8d8ad6b588fd433ee67acf";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

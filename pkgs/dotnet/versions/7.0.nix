{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v7.0 (maintenance)
{
  aspnetcore_7_0 = buildAspNetCore {
    version = "7.0.14";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/7a1d3e1e-ede9-4b28-a9c8-3023858b7f01/c9214ad6a85286f4abd026d23dca5d3c/aspnetcore-runtime-7.0.14-linux-x64.tar.gz";
        sha512  = "00f55556cb580d81bf0059a61a642ed8b405452d55e94460c03a0edec9a4f608fd78561560e5fc5bf6e42fb1f45420eba75f8d102d8bd46686379dab7ffde6f6";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d7ed165d-32b2-435f-a747-9683d4f89354/3372ce43201a1977c30bc8236bf0443d/aspnetcore-runtime-7.0.14-linux-arm64.tar.gz";
        sha512  = "577d927686639241c00e2f07fcb11eb878d671e926c6fc058f879619452ab0af675db4c2dfd8aa9290f03cb11afcf5094be1beeb5fae491f50520e171e732a71";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9d6a0fb7-65bd-4f61-8558-e545af46fee5/f16d3fccf91fde1481c04314fe851e2a/aspnetcore-runtime-7.0.14-osx-x64.tar.gz";
        sha512  = "37f526b1192f67792aa413f6035a6e67bb42cbbab7b240ec0194a0640ca08e98546796e751fe1700990b2c2c0b71ddc3516571536f1110b4db47b2a1b44301d3";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c3308f4f-65c9-4855-99d3-21657f401854/d12446cf25f3fca12438881117d5b292/aspnetcore-runtime-7.0.14-osx-arm64.tar.gz";
        sha512  = "17f0c996b2e5586385b2e6cdcb187fce27e0c18f235c4198df9a2bac5475467fe6c9df6405e7cd75ad4bb1a5f6ce380e23330cb1a047c5930aeac9c6c89772ab";
      };
    };
  };

  runtime_7_0 = buildNetRuntime {
    version = "7.0.14";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bece81ac-e35d-40e3-8b07-cf5b0c4872d9/d571e657adc85ec66141a82dd3ef8fea/dotnet-runtime-7.0.14-linux-x64.tar.gz";
        sha512  = "02fd66ef2059d124d9c4f3fbfd0d5b0375b83610cdf51a2972567e4bdaf1d55e532478533509ec2408c371e7fdd6efea8e9b9aec9eb5cd703e8e5d2814ef319b";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6c6534cc-0798-4fc7-bc45-1101fd627181/4846e3b3bfd3570d2c6f3e3b6711efef/dotnet-runtime-7.0.14-linux-arm64.tar.gz";
        sha512  = "cf2dc2997b10148b558f78b2f2401acc83921a6b721c11199ac7dc77d8c9fb5500d7be092281f13f3c9b4287dedc6fdb56f242d9340568a0fc021055983f9cd8";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/49878be9-1cba-4e7d-943c-b0f6cf5abd71/1f4d396b60584080d4bfee86269a5e0f/dotnet-runtime-7.0.14-osx-x64.tar.gz";
        sha512  = "74f66428fdc77ae9d801e1f7559d99436c6d1fbee7a64d587e46637466873a32d76b867f5cf56c0951bb01450419b8f25e851e5ed0abe69444df8979312cf9a0";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/dcede156-7e96-4b45-b750-c0a4893448d7/8ab02359114d9f4930baea23f3b418be/dotnet-runtime-7.0.14-osx-arm64.tar.gz";
        sha512  = "0de7be8aa01c837ef587e9ed8b2944ef600466a2b68c6f0a4c63e1d4473b92a09667a31a412cc2535b8ca44a0f768cd1a1daa419ad152f2d42c3513fab35eaf5";
      };
    };
  };

  sdk_7_0 = buildNetSdk {
    version = "7.0.404";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9c3e1dcb-485a-44cf-b1cb-d6c0b643d805/d4b2a46283254b6d68f61ee3f1a06952/dotnet-sdk-7.0.404-linux-x64.tar.gz";
        sha512  = "f5c122044e9a107968af1a534051e28242f45307c3db760fbb4f3a003d92d8ea5a856ad4c4e8e4b88a3b6a825fe5e3c9e596c9d2cfa0eca8d5d9ee2c5dad0053";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2157e304-6f7a-4646-8886-05cc0dba157d/4cecdaeec9fd4715d0eee8987f406c21/dotnet-sdk-7.0.404-linux-arm64.tar.gz";
        sha512  = "b7131829d08dadbfd3b55a509e2d9a9de90b7447e27187bd717cebf1b134bd0ddfcb9285032f2ce08bd427487125e8b3e9cdc99b7f92436901e803e65f1581de";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/555d267c-fd4f-4431-93b6-d135cc1b1753/de1e43b9ade16f748a7e0c528bdc1498/dotnet-sdk-7.0.404-osx-x64.tar.gz";
        sha512  = "6e04e1d262c23bc0fbd6be9b1f847c1a47142438b330c004e46b49aaf0a520df3f3c0a576b2fd0ed88567be572280e5f5a98908c920108c58e65aef22c1332d0";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f2df5209-a44a-4567-9a8e-56ad008fe383/c851463feae2305adeaf9466890deea9/dotnet-sdk-7.0.404-osx-arm64.tar.gz";
        sha512  = "ca2dc7a126aeb8ab6c919bab535eccc47817666feaf0cde7418cab0a2cee238ec44d229b3f4d1f7550d121748f1e0abc5e4900b33edd57f2cccd89b58fe84f49";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

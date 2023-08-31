{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.21";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/56d44b17-03c2-4d9e-bdbc-a598ca34fc01/8fcc1e19dfd3c86b09beb68460db6e85/aspnetcore-runtime-6.0.21-linux-x64.tar.gz";
        sha512  = "3a74b52e340653822ad5120ec87e00e4bc0217e8ce71020ad9c4a0903b87d221b538c3841949be2ca129a45f8105def0ea5152e44e7cef8858958ae04fa0dd65";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/1f8d7d02-581b-42f8-b74a-bf523099ab5c/29da812824f1a8cdfbe452aa5bc0ebc3/aspnetcore-runtime-6.0.21-linux-arm64.tar.gz";
        sha512  = "3d39f458831c2e2167c06eb85205a764e9aa497ccc26cb19968f03cb3102daaafde391a707f08c3010bff95cfc0e9586ea97c0fe7d8ef885b4aae009748591c8";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4eece21f-af5c-4bdd-8e5b-5e300f0cbc6d/5290c217803341cb2a51628e8ea0dd9e/aspnetcore-runtime-6.0.21-osx-x64.tar.gz";
        sha512  = "b7d604bc11224b32960f11ed2332cfe5cd595655dad5c2cae1fba40e73ec637f9f6e4246659296d90f544d7aa7c5248b0c7999cf82b4a325acef7368416c1dde";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a6bf9946-7321-452d-8dfb-120ea0911a6a/9d77b20bb6802d0e8a4cdeda58fddaee/aspnetcore-runtime-6.0.21-osx-arm64.tar.gz";
        sha512  = "bd1cf2252d61ab88e39d7cf6e7b57168363f599de7e2aafafa9f2373976c97653e83cbfff5d1708276b6503f8a21f60af8c8601835c4d6e0b603b3c4bb90902f";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.21";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/25fc0412-b2ff-4868-9920-c087b8a75c55/a95292a725fc37c909c4432c74ecdb43/dotnet-runtime-6.0.21-linux-x64.tar.gz";
        sha512  = "9b1573f7a42d6c918447b226fda4173b7db891a7290b51ce36cf1c1583f05643a3dda8a13780b5996caa2af36719a910377e71149f538a6fa30c624b8926e0cd";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/934fe9da-efb0-47e4-8db2-4d2153c7fe0c/e382d2a3169ac6a8288f09c9077868c3/dotnet-runtime-6.0.21-linux-arm64.tar.gz";
        sha512  = "f34e1319ded1e1115ceb63eab16a4ac7096e36e3236f8117f61ec9f0e19dd50adb473e1213a1018abfaedc4da57519b85058e7b14187a33e0b91e79af4dabf63";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/af927c74-8c04-4aac-9597-3b56902a812a/47139a25bbc5e58b24fff42f6af0da7c/dotnet-runtime-6.0.21-osx-x64.tar.gz";
        sha512  = "f34a597910eccb84eec683f75f3ea8b6bdfc33a81388face050e33df679863465c905c0c99cdbfc54b3eb2b2a58733f7185a18234e562b1af5c925fa44dcb84c";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4c3bd8fc-abdb-458d-a675-aac97584babb/35b8a258af87daac35bab7db1af0ff9b/dotnet-runtime-6.0.21-osx-arm64.tar.gz";
        sha512  = "e5a853ee04890e0466489fc46e3cfb8c665aeaacda8646b6958337cb16aeb0edbcf6d4131d31510b12852262fdb466f4d9352e0818a7ecb7e00e4e3a5e5755e1";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.413";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8eed69b0-0f3a-4d43-a47d-37dd67ece54d/0f2a9e86ff24fbd7bbc129b2c18851fe/dotnet-sdk-6.0.413-linux-x64.tar.gz";
        sha512  = "ee0a77d54e6d4917be7310ff0abb3bad5525bfb4beb1db0c215e65f64eb46511f5f12d6c7ff465a1d4ab38577e6a1950fde479ee94839c50e627020328a702de";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/82132239-803b-4800-971e-ded613cc280a/67d0025a0a54566657c3e6dfeb90253e/dotnet-sdk-6.0.413-linux-arm64.tar.gz";
        sha512  = "7f05a9774d79e694da5a6115d9916abf87a65e40bd6bdaa5dca1f705795436bc8e764242f7045207386a86732ef5519f60bdb516a3860e4860bca7ee91a21759";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/398d17e1-bdee-419a-b50e-e0a1841c8a3c/2e8177e8c2c46af1f34094369f2219be/dotnet-sdk-6.0.413-osx-x64.tar.gz";
        sha512  = "605b28135dbc8c34f257ea1d10d02edb16569957e554ecc49c2a9fbb4200960b2fe21a06f2b770a9907fa915ebef0e6260704cc9e05a81af931f10dce7f46165";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6152c11b-e65d-4b60-8fc0-3c506a6199d2/c9f1ce3f1fc5bc6fa758fac505845232/dotnet-sdk-6.0.413-osx-arm64.tar.gz";
        sha512  = "e3a24cdcb80b2e283cd93ebb0af4ad891ecb5f2002d56b82a379d5d99b934a58f5ae60d07d21052360f525692fcf7bfde0c678c5d7f9908101fdd2096bea4458";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

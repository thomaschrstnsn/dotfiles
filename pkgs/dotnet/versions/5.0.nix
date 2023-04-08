{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v5.0 (eol)
{
  aspnetcore_5_0 = buildAspNetCore {
    version = "5.0.17";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/a2b96f83-e22a-4fa6-a10e-709b3effac9a/0d6ade6c0ceebc8ef7dbf2b1a6d86f17/aspnetcore-runtime-5.0.17-linux-x64.tar.gz";
        sha512  = "d8e87804e9e86273c6512785bd5a6f0e834ff3f4bbebc11c4fcdf16ab4fdfabd0d981a756955267c1aa9bbeec596de3728ce9b2e6415d2d80daef0d999a5df6d";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6eb8aee2-cbea-4c4f-9bb9-ea6229ec229b/d6c438e5071c359ad995134f0a33e731/aspnetcore-runtime-5.0.17-linux-arm64.tar.gz";
        sha512  = "ac1a9d89f1b730dfdca9c2e48373ef21f8f9316014eefbe6b11516f8195d3b3efc4e482883774b74ea2ff1cb77174a2cb471bd1157ab5b7d71621e3026c38e9b";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/25e4817f-6fd0-46dc-be0d-d819445bac5c/a8fa228c872df683741c8a79745f8fb3/aspnetcore-runtime-5.0.17-osx-x64.tar.gz";
        sha512  = "bb0c43c723090fa2d8a0255e6fc8c004ebe7baf2d5d56e22ad2e6336a67fe415333d451e459c8857c0ccb5819d998232c9617bf45f222559d4b8891b0af41f20";
      };
    };
  };

  runtime_5_0 = buildNetRuntime {
    version = "5.0.17";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e77438f6-865f-45e0-9a52-3e4b04aa609f/024a880ed4bfbfd3b9f222fec0b6aaff/dotnet-runtime-5.0.17-linux-x64.tar.gz";
        sha512  = "a9c4784930a977abbc42aff1337dda06ec588c1ec4769a59f9fcab4d5df4fc9efe65f8e61e5433db078f67a94ea2dfe870c32c482a50d4c16283ffacacff4261";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6690730f-cf10-40f1-9d4d-4c0d002f22d0/e117133858f190c169873200b8d7b9d7/dotnet-runtime-5.0.17-linux-arm64.tar.gz";
        sha512  = "99cb11871924d3abedcc9c8079c54bc0c550203c7cbe4e349ed70d4355f40e4620b68d90b797e6461d898c06bed6953580e2cd4ad01483e5de107ca5a3409610";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/39326cf0-dc7f-42a3-9f7a-fe30c75c7a7f/33cbce552148e13d47120fe4502f5b5e/dotnet-runtime-5.0.17-osx-x64.tar.gz";
        sha512  = "31add512418640f98bc9511509db2049a2674c7725169d26be89218a02ac7972e03e5d6be5a3d45a0dfa764e6eade503a8f4957b7b198ec6ad412e423d95f1b9";
      };
    };
  };

  sdk_5_0 = buildNetSdk {
    version = "5.0.408";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/904da7d0-ff02-49db-bd6b-5ea615cbdfc5/966690e36643662dcc65e3ca2423041e/dotnet-sdk-5.0.408-linux-x64.tar.gz";
        sha512  = "abbf22c420df2d8398d1616efa3d31e1b8f96130697746c45ad68668676d12e65ec3b4dd75f28a5dc7607da58b6e369693c0e658def15ce2431303c28e99db55";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d4b71fac-a2fd-4516-ac58-100fb09d796a/e79d6c2a8040b59bf49c0d167ae70a7b/dotnet-sdk-5.0.408-linux-arm64.tar.gz";
        sha512  = "50f23d7aca91051d8b7c37f1a76b1eb51e6fe73e017d98558d757a6b9699e4237d401ce81515c1601b8c21eb62fee4e0b4f0bbed8967eefa3ceba75fc242f01b";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/4aeecc7c-7ffa-418f-9362-cf5eb3ed0396/055d5e6064a9fdecd7d906f5f262373d/dotnet-sdk-5.0.408-osx-x64.tar.gz";
        sha512  = "3fdd4deac2809b00c0f669d5488000ac1b9a47dee6ab7b31167d7cec4759a10ee347fd4f52090a40684e5ecc1e1f57eb99c558e561edfd1436a2f77fc1c1a0b2";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

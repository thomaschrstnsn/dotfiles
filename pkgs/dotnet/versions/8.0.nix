{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v8.0 (active)
{
  aspnetcore_8_0 = buildAspNetCore {
    version = "8.0.0";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/257bdcc7-cbfd-4680-964a-cbe8e9160bca/ac0cbf19d897ba51ae004b4146940a0a/aspnetcore-runtime-8.0.0-linux-x64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/6c37b740-be2b-4560-9caa-5f45b0f2cb80/6ba5f7ab4e5f815ddeb0644d5f8360a4/aspnetcore-runtime-composite-8.0.0-linux-x64.tar.gz";
        sha512  = "c0aa3a926d6c2bc0d4cc14f5d7677a4592111bf3ebefa65c5273c4b979a6e2b5d58305a5aaf4ac78f593b46605ec02f40b610dcbff070b1d8cf8ddc656cac7dc
b7f2cf8cf6496a438b03e6e945d776a763c388127b98b7cc20bb86c0e9570c40890e0397f55dea6d8f9aabfbec88dae3800eb2b87462a765a54ecdd7d68c75a3";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/91223e4e-2300-4e8e-9364-09ea1c317294/47fb26a2df5eeee08f77a4d1b720a34a/aspnetcore-runtime-8.0.0-linux-arm64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/30405043-c6ed-4017-8835-ec073190cf23/342685692dc5beedbb49ad72bf413e83/aspnetcore-runtime-composite-8.0.0-linux-arm64.tar.gz";
        sha512  = "f9e1ae263dd944c70ea1818a3a44bb62aa5bfb65dafa463dc9f9a33bc8ad1c60b4e7a364a7414cc00a01ff707b5e88fc52c520edf0eb357ed1ddf4a8fcd8eae9
8e3d2fbb491a97b31510d5c69890f4b37520e2141fbef1b9bd8ab0617f08d506246c8c411c05369b1a747e56440027953aae7eb015ae41183fa092e7d87a366a";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/6ef899a5-571a-4fd3-b294-65665d9cc76f/d21cc874f3832a5e0ad583d948d1f228/aspnetcore-runtime-8.0.0-osx-x64.tar.gz";
        sha512  = "1b19d90b631ebd74f6e1f4343ecf54f6f04bc8a2aceebbca66de57d41d440a66c7f56565043c1aaeb77b586dc349914d7d30b8c066197840430d543c24c87539";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0d05d563-f3ce-4d40-8cd8-f28247510533/48ed8322af7e47c2f68fc0afbd65e37b/aspnetcore-runtime-8.0.0-osx-arm64.tar.gz";
        sha512  = "0edb1bd0655d7898d9a02f7127e9a93af7e92e3ea324a7d77e9634b5dfa0851184d784f2573612b18bc37cb0510f93d1b0eaa2ae56b6ca99a16f1edafe6cf8fe";
      };
    };
  };

  runtime_8_0 = buildNetRuntime {
    version = "8.0.0";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fc4b4447-45f2-4fd2-899a-77eb1aed7792/6fd52c0c61f064ddc7fe7684e841f491/dotnet-runtime-8.0.0-linux-x64.tar.gz";
        sha512  = "16a93af328bcf61775875f4007c23081e2cb7aa8e2fba724aea6a61bc7ecf7466cc368121b08b58ac3b72f68cb67801c68c6505591eb35f18461db856bb08b37";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c879318f-48f3-4cc4-8dcc-a6b77cfdfc38/7890f8a96ea335f5265cd1aa80cac8ce/dotnet-runtime-8.0.0-linux-arm64.tar.gz";
        sha512  = "bb39fed4cff3a1a0a4e5084a517feeacb571700b8114b83b0b040f63f279d32eb9195d9b94cd60f8aa969b84adaad51694a2e26255177a30f40f50f634d29c21";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/65e0ad28-b73d-46ab-b3ae-2d2ae4460b78/50ee103e816a255f9a5331bc2975a6ef/dotnet-runtime-8.0.0-osx-x64.tar.gz";
        sha512  = "a469d4fcbd756861045a2f639f42e7f7296fea3c5cb5bfbe75a9deefae2c5fa1fd658b35fe378e2a4afefcc37d8d874908833728481cc4b18fbd9f6f204d684d";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/65665fae-8f24-4214-89b5-980dbad7be30/1b70f4b76e076b4b656879426e861fbd/dotnet-runtime-8.0.0-osx-arm64.tar.gz";
        sha512  = "5464e6ca9afa89680b71042e200e99c43855a216cfef64ed2cc0b44efe547f7f69e57559ecdc47404e2a8c1c2b0f7d00ebcfc8b949750f0af168eb575e7dc092";
      };
    };
  };

  sdk_8_0 = buildNetSdk {
    version = "8.0.100";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/5226a5fa-8c0b-474f-b79a-8984ad7c5beb/3113ccbf789c9fd29972835f0f334b7a/dotnet-sdk-8.0.100-linux-x64.tar.gz";
        sha512  = "13905ea20191e70baeba50b0e9bbe5f752a7c34587878ee104744f9fb453bfe439994d38969722bdae7f60ee047d75dda8636f3ab62659450e9cd4024f38b2a5";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/43e09d57-d0f5-4c92-a75a-b16cfd1983a4/cba02bd4f7c92fb59e22a25573d5a550/dotnet-sdk-8.0.100-linux-arm64.tar.gz";
        sha512  = "3296d2bc15cc433a0ca13c3da83b93a4e1ba00d4f9f626f5addc60e7e398a7acefa7d3df65273f3d0825df9786e029c89457aea1485507b98a4df2a1193cd765";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e59acfc2-5987-43f9-bd03-0cbe446679e1/7db7313c1c99104279a69ccd47d160a1/dotnet-sdk-8.0.100-osx-x64.tar.gz";
        sha512  = "8ab6a1408e630a7f689414ad062191558c363f8fb8a98b6571ed99d386c07951655c6a499f8b8a4b128d4f566b7a67b6e8be26cda751d9286851b603096d0da2";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2a79b5ad-82a7-4615-a73b-91bf24028471/0e6a5c6d7f8b792a421e3796a93ef0a1/dotnet-sdk-8.0.100-osx-arm64.tar.gz";
        sha512  = "11a307ec17fa11fd8f133d697cd414c12b1d613ef9ec05db813630b10a00cb2ee0f703580688bc59b60c911e97a27eef8ae0d89fc2298c535e0bb15b5b997bc5";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

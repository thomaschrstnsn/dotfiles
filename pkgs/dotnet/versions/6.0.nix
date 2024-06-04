{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v6.0 (active)
{
  aspnetcore_6_0 = buildAspNetCore {
    version = "6.0.31";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c8c7ccb6-b0f8-4448-a542-ed153838cac3/f104b5cc6c11109c0b48e2bb8f5b6cef/aspnetcore-runtime-6.0.31-linux-x64.tar.gz";
        sha512  = "ebb20a3461bf9d1e3a5c91761452f5ef2e60873826ad3158493768a18d207319bccc40d6c1a64fd61dd8c22bad51c26689394b0e6a40c4bfe4cca00ce4c00db1";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/088b0ba5-2eaa-4815-a5c2-3517b99d059c/f6d18014064903be5fa2f654f51f5ce0/aspnetcore-runtime-6.0.31-linux-arm64.tar.gz";
        sha512  = "5d395554520a62c81e01f045245749d771d728a353631879462ac499e78658377e475bca756668eeafdd65ac55ad55f244f778809c127a553c5c330b76ef9dd8";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/9b9addf2-5f49-4d1d-8272-bc348c9d93e4/a4dc2cdc0dcf8215a1c7e436a4c854cc/aspnetcore-runtime-6.0.31-osx-x64.tar.gz";
        sha512  = "79ced204af5aff757fc7680298121269bdc770b62411750f913d3129dad79c8b2eabd54b2986073c219b3aaa4b49f7188ab7694b99361fb725bff8e32db07dc3";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/299cb3a7-badd-474f-9906-33d744bd77e7/cfb103fc34184ce82a012c5a1046292a/aspnetcore-runtime-6.0.31-osx-arm64.tar.gz";
        sha512  = "f19e54b4a4e42db7aae880b86a6dde57dc988aebf852008b70ae56f89ad130e0aba73903357f4e97ead10d013ae3fa7fd28d197ef88f0742391f601ff136951b";
      };
    };
  };

  runtime_6_0 = buildNetRuntime {
    version = "6.0.31";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d67d6174-70c0-4256-b4f3-1f06cb5e8499/4bb51048eee17bda6b0ab7887c227206/dotnet-runtime-6.0.31-linux-x64.tar.gz";
        sha512  = "8df8d8bfe24104f41cc9715bb04fdc1811426c4d16f29336607c68a30d245fb8f36577d639e7da4865204fa85280fb5cdcf47e93183afe6b9e946e0c53df32c8";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/34215580-c4c9-49ee-a9a1-e9cb1a25646b/9ac060d3bd7eaf550d11acd60bd2841a/dotnet-runtime-6.0.31-linux-arm64.tar.gz";
        sha512  = "022c7fc8878544f8abde8cf13ef661327238381c8f4731b4975be294616fda00a4b093036a896baef99eb58b881890d3fa951cc51b0212e766a8a7ce95d2c440";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e06ea94c-e84e-48c3-9bcb-5fc65db7701b/22612902257c79e6483990c0d9bf02b5/dotnet-runtime-6.0.31-osx-x64.tar.gz";
        sha512  = "fb6ae3a5f5f31078cbc98d06101ed53b6a23e9a5582c3d660850e7315fe21d776ad2c3ec716ce27cc0ac87c37d99c6dd9bc864d9410917aa4c73cd885010980a";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d82928b9-3ce6-4060-bdd5-159afb165b37/002421f6104e66b92b7abb31abe7ffed/dotnet-runtime-6.0.31-osx-arm64.tar.gz";
        sha512  = "57d89d189fd7c33ae9627a06dd543d4783c1e04376173e4a2868a342ca864323e41d5a4050dd82fbd9d7947ca1ea12185e80294c70857b97e3d32eace15940cc";
      };
    };
  };

  sdk_6_0 = buildNetSdk {
    version = "6.0.423";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/111a63f5-e1d4-4d07-b8b2-98642b5fcc59/389661b982fa5b83b09a1f50b9da247a/dotnet-sdk-6.0.423-linux-x64.tar.gz";
        sha512  = "4b4a0e66634211ae04fa030e18ae9e22640f5828307ba85c4bae596ab2d31260519197828dae3b2ec73d6772635e0b375536ea6591b03c67c2b7a5566f016952";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/f60a9d6c-1df8-4b84-af48-1961ed476a38/32f60a0f291dce64fb33a502e69e78bf/dotnet-sdk-6.0.423-linux-arm64.tar.gz";
        sha512  = "42f5e89d6d9a9923bbc20398a6272290b5f693cc767aa540233630f849779daa8cc7d8ac87655f6b2c8e0250bf5be986a8e8ae502b6f33c0b3e474d041b77625";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/8e5dec4f-d683-4ffa-9704-f4af023d5383/483bb54f830379d5eedd21c47ccaf47b/dotnet-sdk-6.0.423-osx-x64.tar.gz";
        sha512  = "31d8f5aa5b0fc5de1c6f809920cc8ffa0415059daa12ed21888795e600b528376d7b14da5b946ae5493af7214543e6494d9afc8ca017d05ee56dbfd10e2fade0";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c53f9a57-8f7c-4d78-a2a5-32ddcf142cbb/312e8c418f6dd2372dd0e9174b10e6dc/dotnet-sdk-6.0.423-osx-arm64.tar.gz";
        sha512  = "fb31894ae43764c518d7909859a2b598134bc03bbb7996ad0badc1088cfcf4d666f25746f77cfef1aa042c2f9fdb348e6975e1c4a98ff93c1b206a4a0429f995";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

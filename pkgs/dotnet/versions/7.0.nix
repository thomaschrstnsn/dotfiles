{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v7.0 (active)
{
  aspnetcore_7_0 = buildAspNetCore {
    version = "7.0.10";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/08af0433-9ec3-4604-9d1c-85e3922a4524/396b340b4ee38765d7462e2fc61a5e3c/aspnetcore-runtime-7.0.10-linux-x64.tar.gz";
        sha512  = "580fdda88824bde6b2d5c09eb009fef64e89705a8aa096dc71338a549969842dff8d9f6d4bb4651e60b38e44ed0910ec18982a062b471ace18c2e22348de11ab";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/712946ec-0b43-436c-abfb-3abab81f6cad/c83ba8df4dab39957ffa5e93604f0b32/aspnetcore-runtime-7.0.10-linux-arm64.tar.gz";
        sha512  = "83d3fc657328f127ea8881844dda2f91fa03f2157f5c76acda64cd091e430fa7d812b3984b803ac624b171f18a5eab3c7b5791a02baa68eddcaf7498709f982d";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d10c9d59-a624-4175-9069-4a13fcf9a1c4/427bb8da02c7907bc2f3115144c1515f/aspnetcore-runtime-7.0.10-osx-x64.tar.gz";
        sha512  = "1f1fbfb0851d62538aa6feacb5c38c14289e7b2d19be62c0e240da6d3c9336f3223eaa2f3e64559e6d8f599a33d9f8dd3d138998386ee9532854139b3275812a";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/516a672c-9216-4592-be66-a628a166b583/fec0aa593bc700a5f5d3860abf1a4af8/aspnetcore-runtime-7.0.10-osx-arm64.tar.gz";
        sha512  = "95c987c38b80b1083016ff360c957ac4cbc2aad406f87095f7350704de8b9a23ae060e551166c396cadeb54f39f176d5a1bbf77704edaf0c0a308d87ca29b838";
      };
    };
  };

  runtime_7_0 = buildNetRuntime {
    version = "7.0.10";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/e9cd1834-1370-4458-98f6-d0d035dcd41e/6d2ca4b900398e717287ad0e75eb9a3e/dotnet-runtime-7.0.10-linux-x64.tar.gz";
        sha512  = "f15b6bf0ef0ce48901880bd89a5fa4b3ae6f6614ab416b23451567844448f2510cf5beeeef6c2ac33400ea013cda7b6d2a4477e7aa0f36461b94741161424c3e";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/023e4544-e6f6-4d2a-ab91-ff63eff97db5/26c02c09fe3a5d57248caa0a0d9e8254/dotnet-runtime-7.0.10-linux-arm64.tar.gz";
        sha512  = "e90b68b272d5db7cf8665bf052fb0300d50a69818d70675442dc891654d140f7f84527b849860589bf152de1d00aa55dc15ee32f5678d46ea0069210fd002b03";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/b6caa3ca-cb18-4891-b188-aa661741ec01/5df34b59b10e79714bac97cfdd6e86db/dotnet-runtime-7.0.10-osx-x64.tar.gz";
        sha512  = "6b992fbbc673d5005f2412839c632f772f6576c9ff95d44afaca478a79597601b306e1f1c496836549474a2c35238943ba27eef5749b1a2bbdd8f36553ad145d";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/fd4660d9-e747-42b7-abe9-eaedff0356ca/8a6f41f5ee23ed510c442d1350bda8d3/dotnet-runtime-7.0.10-osx-arm64.tar.gz";
        sha512  = "f578e00d5bd144c51e5d71adbd8e0ecc97f7e8ea06263c585785b41ffbb590537f5a18b63a78e45e90e798cd66fa45285059226b1904f4c2d4e2ea40c2c71bbd";
      };
    };
  };

  sdk_7_0 = buildNetSdk {
    version = "7.0.400";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/dbfe6cc7-dd82-4cec-b267-31ed988b1652/c60ab4793c3714be878abcb9aa834b63/dotnet-sdk-7.0.400-linux-x64.tar.gz";
        sha512  = "4cfeedb8e99ffd423da7a99159ee3f31535fd142711941b8206542acb6be26638fbd9a184a5d904084ffdbd8362c83b6b2acf9d193b2cd38bf7f061443439e3c";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/16b0b1af-6eab-4f9e-b9a4-9b29f6a1d681/4624e54b61cae05b1025211482f9c5e9/dotnet-sdk-7.0.400-linux-arm64.tar.gz";
        sha512  = "474879abcf40d4a06d54e02997a3fb93dd10c8d5f0dfd5acbf7e1a6f493a6d3421e426431d512b482c62cda92d7cda4eddd8bab80f923d0d2da583edaa8905e8";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/1a603c4a-7e79-44ef-8e09-426a2c1c6e60/eb3dea0e50d73fbf28edf88aa8378e38/dotnet-sdk-7.0.400-osx-x64.tar.gz";
        sha512  = "e705c7466c9aa0c1203e0795ced23c6b794285ef60c8f7e1d199a09e596c20180901c2ec9c24483afa6302afb46a6b87ce18533283e2223a2161776f25421f61";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/3df92af2-c066-403b-ae65-10b7ec879b32/a4a5a807d92510d5b74ee8fef9b2babd/dotnet-sdk-7.0.400-osx-arm64.tar.gz";
        sha512  = "134f764680336481a67ded13af8f9ce9e89e29937c7998d8e6a3695593dd1246b8d9407649f125032a3057c138b9739aef3bf8e3acdf0220224417c2036bf159";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

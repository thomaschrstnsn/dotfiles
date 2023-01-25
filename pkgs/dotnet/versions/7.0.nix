{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v7.0 (active)
{
  sdk_7_0 = buildNetSdk {
    inherit icu;
    version = "7.0.102";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/c646b288-5d5b-4c9c-a95b-e1fad1c0d95d/e13d71d48b629fe3a85f5676deb09e2d/dotnet-sdk-7.0.102-linux-x64.tar.gz";
        sha512  = "7667aae20a9e50d31d1fc004cdc5cb033d2682d3aa793dde28fa2869de5ac9114e8215a87447eb734e87073cfe9496c1c9b940133567f12b3a7dea31a813967f";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/72ec0dc2-f425-48c3-97f1-dc83740ba400/78e8fa01fa9987834fa01c19a23dd2e7/dotnet-sdk-7.0.102-linux-arm64.tar.gz";
        sha512  = "a98abed737214bd61266d1a5d5096ae34537c6bef04696670d88684e9783bab6f6d45823f775648d723c4e031b1bd341f771baa6b265d2b6e5f5158213721627";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/91c41b31-cf90-4771-934b-6928bbb48aaf/76e95bac2a4cb3fd50c920fd1601527c/dotnet-sdk-7.0.102-osx-x64.tar.gz";
        sha512  = "b7a66a6dc9e6648a97a2697103f2a53f37cab42d7dbd62b1f6ce5b347ca6cc7e45e5474ddb546e10f1e49ac27b20c0f58936093decf779941afd2ff761ecf872";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/d0c47b58-a384-46b3-8fce-bd9188541858/dbfe7b537396b747255e65c0fbc9641e/dotnet-sdk-7.0.102-osx-arm64.tar.gz";
        sha512  = "bc95a0215e88540bd52098453f348edb01ffec11ccfc44c7c017bfae5243ce2f0a50f4bb06cc6c3a622c9fc27b89f026be172c2d1bfb8ba62ed007071d5224b5";
      };
    };
    packages = { fetchNuGet }: [ ];
  };
}

{ buildAspNetCore, buildNetRuntime, buildNetSdk }:

# v8.0 (preview)
{
  aspnetcore_8_0 = buildAspNetCore {
    version = "8.0.0-preview.7.23375.9";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bd304ca6-9f08-425e-8add-a607c69e9725/4665c7ac5984dc4eb0e9635075d07d0e/aspnetcore-runtime-8.0.0-preview.7.23375.9-linux-x64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/67db37a4-07dc-49cb-bd61-51ceb024640e/97960939b0895ee67366636f33f3d950/aspnetcore-runtime-composite-8.0.0-preview.7.23375.9-linux-x64.tar.gz";
        sha512  = "b8c8a5cd579a8ee1e082363a73a05a745499365445f784e6ff87547f9acdbe8b7ba525140ef10555bc2802c13af131c2d568ec6af020bd0dd2fdf82d4c258442
fd0573b40e3c007a02e8ca4c4c7486f6414249853712ffd3509d13bec0ece6f4b108c631d32188a9e68d562aa199c691472171572104707b8de8e5ac4958163a";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/7fedb243-5d2c-4718-b08b-da0dc9d32973/f02a41417d762839b4d1559610485727/aspnetcore-runtime-8.0.0-preview.7.23375.9-linux-arm64.tar.gz
https://download.visualstudio.microsoft.com/download/pr/a230090a-1d7b-4426-af95-bb3eb6065109/c5dcfd432ecc08e0368d51d3875ed5e4/aspnetcore-runtime-composite-8.0.0-preview.7.23375.9-linux-arm64.tar.gz";
        sha512  = "8c4b4b36083d2b9c50e7f000d925f8a1cf0eb863367724892a12332970a6988afaf6a070efb97dfa3919039b780bb3a235fc51902c3762a4b5cd918f3082490c
a6831c7d5e0b2516290224c57c8a410ad6943100cc3cf45be25cbf3a7b45e3ec933dc5f5d291c6d421ea9d2bf3c19f1102a9f5ad5d8a2ae4ba72ab48d644d325";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/0a2185fa-4359-44a2-8981-eb456379d400/1697af8d11a758987b7c224ccd166769/aspnetcore-runtime-8.0.0-preview.7.23375.9-osx-x64.tar.gz";
        sha512  = "246dd11df597ddb960befb92f6e3e27da9961cbec5898d01c1e49bc7d3b40f5eec1bf1fe0adb7df24c74233f43558aca8106be4d32f2479e340764f385528346";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/dc44be0d-ba81-4e6a-8340-7c67ba692996/96b50edb075bd46955afb0ff66cdaee8/aspnetcore-runtime-8.0.0-preview.7.23375.9-osx-arm64.tar.gz";
        sha512  = "19008a9f08504d262d94d3e24662b4ced5e8a3294629afa008c30f6f3aec26baeb8404e7f8a01b0d3f48f72955b0d09b7a82a624ffe3925f08c5b46da12af991";
      };
    };
  };

  runtime_8_0 = buildNetRuntime {
    version = "8.0.0-preview.7.23375.6";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/814acd71-bbed-49f0-ac4f-db9b1b8a2bd2/bdb4b87d623dfe4314bb61dfb56ac704/dotnet-runtime-8.0.0-preview.7.23375.6-linux-x64.tar.gz";
        sha512  = "bfd8491550178b86a7a72fe06bdc82f0dd66771d5b60d7e4e1133cdde29f84bd57857d846722e027bd209db087123b2d12b2e23590d77991052269fa265814e1";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/bfa8d826-50d6-4631-bbfa-8e1158002834/fadb0bccc1c4740da9b1952df564272a/dotnet-runtime-8.0.0-preview.7.23375.6-linux-arm64.tar.gz";
        sha512  = "980434e91d6f9dcdd91901ef92aca6e15d015d3c4ed9dd92a11bc4bbe535010b8b5f0d0cf774427d529939663138b1523b28534f090ec41a5ab5abd61699909b";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/03ed278e-76b3-4a3c-88fb-6b7a7fe09f7a/491293d96bed63844f7fae8742660a0e/dotnet-runtime-8.0.0-preview.7.23375.6-osx-x64.tar.gz";
        sha512  = "5ba28076f61e794ba586f5e306f3cef98c062505d466c3dec2b91dea2256ca6b65df9f5c40b402b78e968d8d7fcf00b5898e2ae182536fedddf2b782b9aadaf4";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/b0f07cc9-bf03-4d05-98b8-94931afb1be2/b24551aaabec3c788db0538f19b9b288/dotnet-runtime-8.0.0-preview.7.23375.6-osx-arm64.tar.gz";
        sha512  = "e676fb4a6a155a1501aff4f9f90196fe086c52916538258d3cb3384aae52682bbf0656ec37c0c2ddb7d421c2d27991d5ead10861ce02d331ece6b1d55b5bc4e2";
      };
    };
  };

  sdk_8_0 = buildNetSdk {
    version = "8.0.100-preview.7.23376.3";
    srcs = {
      x86_64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/32f2c846-5581-4638-a428-5891dd76f630/ee8beef066f06c57998058c5af6df222/dotnet-sdk-8.0.100-preview.7.23376.3-linux-x64.tar.gz";
        sha512  = "8bc71a586382f0e264024707f2f3af9a2f675dd5d4fbdd4bced7ab207141fb74d7c6492dfd94373505962b8597ae379259d152e4ace93a65dad0f89600afecd8";
      };
      aarch64-linux = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/593a9616-3715-4923-9245-8c803cc56d64/7283f8e0f6cb17e697af60aec748e65f/dotnet-sdk-8.0.100-preview.7.23376.3-linux-arm64.tar.gz";
        sha512  = "454b664a8eca860727bc5c1fd729beb854a0dfee915867f773aba166592a8c63570281c88ce528dc99339e9bcdb8000f0a1ce168bcfd779b3ae2a69ce60d49d5";
      };
      x86_64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/2206f0d7-f812-408f-bed7-ed9bd043768f/ca7eb1331ee61fdd684c27638fdc6a90/dotnet-sdk-8.0.100-preview.7.23376.3-osx-x64.tar.gz";
        sha512  = "5a086a4d0d0910c4bb036f1501593363324324d1664b34b0468a6e2b20b9580611c5855509afa1d934e3814aff6aa6c7af8acaad3ca3be13dcf24a9b4efcafde";
      };
      aarch64-darwin = {
        url     = "https://download.visualstudio.microsoft.com/download/pr/63ee7355-c179-4684-9187-afb3acaed7b2/f2a5414c6b0189f57555d03ce73413a2/dotnet-sdk-8.0.100-preview.7.23376.3-osx-arm64.tar.gz";
        sha512  = "db3167dd5d125ab400f29f9fc982eacec5ab69764323831985f374ccb57e102ee93ed3c607ac5e0fd733718b41cbe9079ec735ca6466f152a6b238a8fee14fe3";
      };
    };
    packages = { fetchNuGet }: [
    ];
  };
}

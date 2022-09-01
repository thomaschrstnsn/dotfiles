#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix gnused

set -euo pipefail

release () {
  local content="$1"
  local version="$2"

  jq -r '.releases[] | select(."release-version" == "'"$version"'")' <<< "$content"
}

release_files () {
  local release="$1"
  local type="$2"

  jq -r '[."'"$type"'".files[] | select(.name | test("^.*.tar.gz$"))]' <<< "$release"
}

release_platform_attr () {
  local release_files="$1"
  local platform="$2"
  local attr="$3"

  jq -r '.[] | select(.rid == "'"$platform"'") | ."'"$attr"'"' <<< "$release_files"
}

platform_sources () {
  local release_files="$1"
  local platforms=( \
    "x86_64-linux   linux-x64" \
    "aarch64-linux  linux-arm64" \
    "x86_64-darwin  osx-x64" \
    "aarch64-darwin osx-arm64" \
  )

  echo "srcs = {"
  for kv in "${platforms[@]}"; do
    local nix_platform=${kv%% *}
    local ms_platform=${kv##* }

    local url=$(release_platform_attr "$release_files" "$ms_platform" url)
    local hash=$(release_platform_attr "$release_files" "$ms_platform" hash)

    [[ -z "$url" || -z "$hash" ]] && continue
    echo "      $nix_platform = {
        url     = \"$url\";
        sha512  = \"$hash\";
      };"
    done
    echo "    };"
}

generate_package_list() {
    local version pkgs nuget_url
    version="$1"
    shift
    pkgs=( "$@" )

    nuget_url="$(curl -f "https://api.nuget.org/v3/index.json" | jq --raw-output '.resources[] | select(."@type" == "PackageBaseAddress/3.0.0")."@id"')"

    for pkg in "${pkgs[@]}"; do
        local url hash
        url="${nuget_url}${pkg,,}/${version,,}/${pkg,,}.${version,,}.nupkg"
        hash="$(nix-prefetch-url "$url")"
        echo "      (fetchNuGet { pname = \"${pkg}\"; version = \"${version}\"; sha256 = \"${hash}\"; })"
    done
}

main () {
  pname=$(basename "$0")
  if [[ ! "$*" =~ ^.*[0-9]{1,}\.[0-9]{1,}.*$ ]]; then
    echo "Usage: $pname [sem-versions]
Get updated dotnet src (platform - url & sha512) expressions for specified versions

Examples:
  $pname 3.1.21 5.0.12    - specific x.y.z versions
  $pname 3.1 5.0 6.0      - latest x.y versions
" >&2
    exit 1
  fi

  for sem_version in "$@"; do
    echo "Generating ./versions/${sem_version}.nix"
    patch_specified=false
    # Check if a patch was specified as an argument.
    # If so, generate file for the specific version.
    # If only x.y version was provided, get the latest patch
    # version of the given x.y version.
    if [[ "$sem_version" =~ ^[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$ ]]; then
        patch_specified=true
    elif [[ ! "$sem_version" =~ ^[0-9]{1,}\.[0-9]{1,}$ ]]; then
        continue
    fi

    # Make sure the x.y version is properly passed to .NET release metadata url.
    # Then get the json file and parse it to find the latest patch release.
    major_minor=$(sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' <<< "$sem_version")
    content=$(curl -sL https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/"$major_minor"/releases.json)
    major_minor_patch=$([ "$patch_specified" == true ] && echo "$sem_version" || jq -r '."latest-release"' <<< "$content")

    release_content=$(release "$content" "$major_minor_patch")
    sdk_version=$(jq -r '.sdk.version' <<< "$release_content")

    sdk_files="$(release_files "$release_content" "sdk")"

    major_minor_underscore=${major_minor/./_}
    channel_version=$(jq -r '."channel-version"' <<< "$content")
    support_phase=$(jq -r '."support-phase"' <<< "$content")
    echo "{ buildAspNetCore, buildNetRuntime, buildNetSdk, icu }:

# v$channel_version ($support_phase)
{
  sdk_$major_minor_underscore = buildNetSdk {
    inherit icu;
    version = \"${sdk_version}\";
    $(platform_sources "$sdk_files")
  };
}" > "./versions/${sem_version}.nix"
    echo "Generated ./versions/${sem_version}.nix"
  done
}

main "$@"
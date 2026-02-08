{ pkgs, lib }:

let version = "0.1.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "timekpr-collector";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "timekpr-dbus-demo";
    rev = "e715451c397bc2f212a438aea69bb6e0b2d33095";
    hash = "sha256-4YjwFDbfysovbpJTj0ZszW3C2otJsGm/iYF6fTOerwg=";
  };

  # cargoLock = {
  #   lockFile = ./Cargo.lock;
  # };
  cargoHash = "sha256-pQWcYUmPZmRaSN+zZISU+YpWxIy4J8rLbnNvbpu+f/4";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    dbus # D-Bus library
    dbus.dev # D-Bus development files (headers)
  ];

  # Ensure pkg-config can find D-Bus
  PKG_CONFIG_PATH = "${pkgs.dbus.dev}/lib/pkgconfig";

  meta = with pkgs.lib; {
    description = "timekpr sampling from dbus to nats";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}


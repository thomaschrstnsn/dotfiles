{ lib, stdenv, tmux, fetchFromGitHub, jemalloc }:

# tmux master, for the window option `pane-border-type` (joined | separate | separate-active),
# merged upstream from https://github.com/tmux/tmux/pull/5433 (13f9aa0) but not yet in a release.
#
# This has to be a full source swap rather than a patch on nixpkgs' tmux: the feature is
# built on master's new scene-caching redraw (window-border.c), which does not exist in
# 3.7b or any earlier release. Drop this once nixpkgs ships a tmux release containing it.
tmux.overrideAttrs (prevAttrs: {
  pname = "tmux-pane-border-type";
  version = "next-3.8-unstable-2026-11-21";

  src = fetchFromGitHub {
    owner = "tmux";
    repo = "tmux";
    rev = "69ca9d507cbc13ef6e1cc413bf9bff91067afc67";
    hash = "sha256-gVDk3vZEAC8PlIrBy0CaX1MIVZuP+4NkXM4iISljm1U=";
  };

  # master's configure refuses to build on darwin without an explicit jemalloc choice
  # (macOS calloc(3) does not reliably zero allocations); upstream recommends enabling it
  buildInputs = prevAttrs.buildInputs ++ lib.optionals stdenv.hostPlatform.isDarwin [ jemalloc ];
  configureFlags = prevAttrs.configureFlags
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--enable-jemalloc" ];

  # `tmux -V` reports "next-3.8", which does not match version above.
  doInstallCheck = false;

  meta = tmux.meta // {
    description = "Terminal multiplexer (master, for pane-border-type)";
    changelog = "https://github.com/tmux/tmux/pull/5433";
  };
})

{ lib, stdenv, tmux, fetchFromGitHub, jemalloc }:

# tmux master + https://github.com/tmux/tmux/pull/5433, which adds the window option
# `pane-border-type` (joined | separate | separate-active).
#
# This has to be a full source swap rather than a patch on nixpkgs' tmux: the PR is
# written against master's new scene-caching redraw (window-border.c), which does not
# exist in 3.7b or any earlier release, so the diff only applies on master.
tmux.overrideAttrs (prevAttrs: {
  pname = "tmux-pane-border-type";
  version = "next-3.8-unstable-2026-08-04";

  src = fetchFromGitHub {
    owner = "redesigndavid";
    repo = "tmux-1";
    rev = "fe8f9ff526abbf141533d1f63402933065205c4c"; # feat/per-window-border, PR #5433
    hash = "sha256-3qSBVMSf+El7lkxgGQtvcRpRYKgD2QyNz5mTzGf04Ik=";
  };

  # master's configure refuses to build on darwin without an explicit jemalloc choice
  # (macOS calloc(3) does not reliably zero allocations); upstream recommends enabling it
  buildInputs = prevAttrs.buildInputs ++ lib.optionals stdenv.hostPlatform.isDarwin [ jemalloc ];
  configureFlags = prevAttrs.configureFlags
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--enable-jemalloc" ];

  # `tmux -V` reports "next-3.8", which does not match version above.
  doInstallCheck = false;

  meta = tmux.meta // {
    description = "Terminal multiplexer (master + PR #5433: pane-border-type)";
    changelog = "https://github.com/tmux/tmux/pull/5433";
  };
})

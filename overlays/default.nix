{ pkgs, system, lib, myPkgs, lldb-nix-fix }:

{
  overlays = [
    (self: super: {
      inherit myPkgs;

      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; };

      # https://github.com/DieracDelta/vimconfig/blob/ec8062dfe4ce0776fea5e42c28e61fe946ce6c27/plugins.nix#L135
      code-lldb = lldb-nix-fix.legacyPackages.${super.system}.vscode-extensions.vadimcn.vscode-lldb;

    })
  ];
}

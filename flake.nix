{
  description = "A nix flake for GNOME workbench";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    gtk-css-lang-srv = {
      url = "https://raw.githubusercontent.com/nix-community/nur-combined/main/repos/shackra/packages/gtk-css-language-server/default.nix";
      flake = false;
    };
  };

  outputs = {self, nixpkgs, gtk-css-lang-srv, ...}:
  let
    sys = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${sys};
  in {
    devShells.${sys}.default = with pkgs; mkShell rec {
      inherit (self.packages.${sys}.workbench) nativeBuildInputs buildInputs;
      LD_LIBRARY_PATH = "\${LD_LIBRARY_PATH}:${lib.makeLibraryPath buildInputs}";
    };
    packages.${sys} = rec {
      default = workbench;
      gtk-css-lsp = pkgs.callPackage gtk-css-lang-srv {};
      workbench = pkgs.callPackage ./default.nix { inherit gtk-css-lsp; };
    };
  };
}

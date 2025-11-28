{
  description = "Pure GNU Determinate Nix Go Workbench";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/*.tar.gz";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ 

        # Core Golang Tool Chain
                go 
                gopls 
                gotools 
                delve 

        # Doom Emacs Golang Tool Chain
                gomodifytags
                gotests
                golangci-lint

        # Doom Emacs Core
                ripgrep
                fd

        # Analysis
                hexdump 
                coreutils 
          ];
          
        shellHook = ''
            echo "$(which go)"
            echo "$(go version)"
            echo "$(which gopls)"
          '';
        };
      });
}

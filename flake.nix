{

  description = "Pure GNU Determinate Nix Go Workbench"; # Add description if missing

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; 
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    let 
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system (import nixpkgs { inherit system; }));
      
      pkgs_x86_64 = import nixpkgs { system = "x86_64-linux"; };

    in {
      lib = {
        buildGo = args: pkgs_x86_64.buildGoModule (args // { });
      };

      devShells = forAllSystems (system: pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ 
            go gopls gotools delve gomodifytags gotests golangci-lint 
            ripgrep fd hexdump coreutils 
          ];
          shellHook = ''
            echo "$(which go)"
          '';
        };
      });

      packages = forAllSystems (system: pkgs: {
        open-andes-go = pkgs.stdenv.mkDerivation {
          pname = "open-andes-go";
          version = "0.0.1";
          src = pkgs.lib.cleanSource ./.; 
	  installPhase = "mkdir -p $out";
        };
        
        default = self.packages.${system}.open-andes-go;
      });
    };
}

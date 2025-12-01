{
outputs = { self, nixpkgs, flake-utils }:
    let 
      # Define systems to support for evaluation
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      # Helper function to get pkgs for a system
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system (import nixpkgs { inherit system; }));
      
      # Use a dummy packages set to get access to pkgs for a target system
      # We'll use this to define the lib.buildGo function generically.
      pkgs_x86_64 = import nixpkgs { system = "x86_64-linux"; };

    in {
      # 1. lib: DEFINED AT THE TOP LEVEL (This is the critical fix)
      # We define a single, system-agnostic 'lib' that contains the builder
      lib = {
        buildGo = args: pkgs_x86_64.buildGoModule (args // { });
      };

      # 2. devShells: DEFINED VIA ITERATION (This is for the workbench)
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
      
      # NOTE: Remove the flake-utils input if you adopt this structure completely
      # OR, use flake-utils to define the devShells and keep the top-level lib.
    };
}

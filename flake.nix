{
  description = "Nix utilities and cross-repo build artifacts for OpenGen";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gensqlquery.url = "github:OpenGen/GenSQL.query";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./lib
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];


      # NOTE: This property is consumed by flake-parts.mkFlake to specify outputs of
      # the flake that are replicated for each supported system. Typically packages,
      # apps, and devshells are per system.
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        ociImgBase = pkgs.callPackage ./pkgs/oci/base {
          inherit nixpkgs;
          basicTools = self.lib.basicTools;
        };
        ociImgGensqlQuery = pkgs.callPackage ./pkgs/oci/gensql.query {
          inherit nixpkgs ociImgBase;
          gensqlquery = inputs.gensqlquery;
        };

        toolkit = self.lib.basicTools pkgs;

        scopes = (self.lib.mkScopes pkgs);
        loom = scopes.callPy3Package ./pkgs/loom { };

        ociImgLoom = pkgs.callPackage ./pkgs/oci/gensql.loom {
          inherit nixpkgs ociImgBase;
        };

        packages = loom.more_packages // {
          inherit
            loom
            ociImgBase
            ociImgGensqlQuery
            ociImgLoom
          ;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [] ++ toolkit;
        };

        inherit packages;
      };

      # NOTE: this property is consumed by flake-parts.mkFlake to define fields
      # of the flake that are NOT per system, such as generic `lib` code or other
      # universal exports. Note that in our case, the lib is equivalently declared
      # by modules that are imported (see ./lib/devtools/default.nix)
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}

{
  description = "Nix utilities and cross-repo build artifacts for inferenceql";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    iqlquery.url = "github:inferenceql/inferenceql.query";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./lib/devtools
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
        ociImgIqlQuery = pkgs.callPackage ./pkgs/oci/inferenceql.query {
          inherit nixpkgs ociImgBase;
          iqlquery = inputs.iqlquery;
        };

        toolkit = self.lib.basicTools pkgs;
      in {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        devShells.default = pkgs.mkShell {
          buildInputs = [] ++ toolkit;
        };

        packages = {
          inherit ociImgBase ociImgIqlQuery;
        };
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

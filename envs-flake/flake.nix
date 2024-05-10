{
  description = "Nix builds of environments and OCI images containing OpenGen tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    opengen = {
      url = "./..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gensqlquery.url = "github:OpenGen/GenSQL.query";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, opengen, gensqlquery, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];


      # NOTE: This property is consumed by flake-parts.mkFlake to specify outputs of
      # the flake that are replicated for each supported system. Typically packages,
      # apps, and devshells are per system.
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        toolkit = opengen.lib.basicTools pkgs;
        sppl = opengen.packages.${system}.sppl;

        ociImgGensqlQuery = pkgs.callPackage ./images/gensql.query {
          inherit nixpkgs opengen gensqlquery;
        };

        ociImgLoom = pkgs.callPackage ./images/gensql.loom {
          inherit nixpkgs opengen;
        };

        packages = {
          inherit
            ociImgGensqlQuery
            ociImgLoom
          ;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [] ++ toolkit;
        };

        devShells.sppl = pkgs.mkShell {
          packages
            = [sppl]
            ++ sppl.checkInputs
            ++ toolkit
          ;
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

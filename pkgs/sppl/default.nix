{ pkgs,
  system,
  ...
}: let

  # relies on specific versions of deps that are no longer present in
  # nixpkgs stable; we must checkout a specific SHA
  nixpkgs-sppl = import (pkgs.fetchFromGitHub {
      owner = "nixos";
      repo = "nixpkgs";
      rev = "994df04c3c700fe9edb1b69b82ba3c627e5e04ff";
      sha256 = "sha256-60hLkFqLRI+5XEeacXaVPHdl6m/P8rN2L4luLGxklqs=";
    }) {inherit system;};
  pypkgs = nixpkgs-sppl.python39Packages;

  sppl = pypkgs.buildPythonPackage rec { # not in nixpkgs
    pname = "sppl";
    version = "2.0.4";

    #  Use a  version of sppl that has Nixpkgs-compatible versions of some packages
    src = pkgs.fetchFromGitHub {
      owner = "probsys";
      repo = "sppl";
      rev = "ab6435648e56df1603c4d8d27029605c247cb9f5";
      sha256 = "sha256-hFIR073wDRXyt8EqFkLZNDdGUjPTyWYOfDg5eGTjvz0=";
    };

    propagatedBuildInputs = with pypkgs; [
      astunparse
      numpy
      scipy
      sympy
    ];

    checkInputs = with pypkgs; [
      coverage
      pytest
      pytestCheckHook
      pytest-timeout
    ];

    pytestFlagsArray = [ "--pyargs" "sppl" ];

    pipInstallFlags = [ "--no-deps" ];

    passthru.runtimePython = nixpkgs-sppl.python39.withPackages (p: [ sppl ]);
    passthru.checkInputs = checkInputs;
  };

in sppl

{ pkgs,
  system,
  ...
}: let

  # relies on specific versions of deps that are no longer present in
  # nixpkgs stable; we must checkout a specific SHA
  nixpkgs-sppl = import (pkgs.fetchFromGitHub {
      owner = "nixos";
      repo = "nixpkgs";
      rev = "35a74aa665a681b60d68e3d3400fcaa11690ee50";
      sha256 = "sha256-6qjgWliwYtFsEUl4/SjlUaUF9hSSfVoaRZzN6MCgslg=";
    }) {inherit system;};
  pypkgs = nixpkgs-sppl.python39Packages;

  sppl = pypkgs.buildPythonPackage rec { # not in nixpkgs
    pname = "sppl";
    version = "2.0.4";

    src = pypkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-QAp77L8RpN86V4O8F1zNA8O/szm9hNa4wWFT13av6BE=";
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
  };

in sppl

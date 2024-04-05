{ stdenv
, fetchFromGitHub
, python3Packages
, cudaPackages
}:
let
  rev = "ba4234a4720512f7dc45d11b8b8fbf449a439c0a";

  #torch-cuda = python3Packages.torch.override (final: prev: {
  #});
in
python3Packages.buildPythonPackage rec {
  pname   = "bayes3d";
  version = builtins.substring 0 8 rev;

  src = fetchFromGitHub {
    repo = pname;
    owner = "probcomp";
    inherit rev;
    hash = "sha256-/Cdm4Syfhm8QFCgKWITvaSGKmDjR38mepQez4xOzH1A=";
  };

  pyproject = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  buildInputs = [
    #cudaPackages.cuda_nvcc
  ];

  propagatedBuildInputs = [
    python3Packages.torch
  ];

  #env.CUDA_HOME = "${cudaPackages.cuda_nvcc}";
}

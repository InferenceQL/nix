{ pkgs,
  nixpkgs,
  system,
  ociImgBase,
}: let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};
  python = crossPkgsLinux.python3;

  scopes = (import ./../../../lib/mkScopes) pkgs;

  loom = scopes.callPy3Package ./../../loom { };
in pkgs.dockerTools.buildImage {
  name = "probcomp/inferenceql.loom";
  tag = systemWithLinux;
  fromImage = ociImgBase;
  copyToRoot = [ loom python ];
  config = {
    Cmd = [ "${python}/bin/python" "-m" "loom.tasks" ];
    Env = [
      "LOOM_STORE=/loom/store"
    ];
  };
}

{ pkgs,
  nixpkgs,
  system,
  ociImgBase,
}: let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};
  python = crossPkgsLinux.python3;

  scopes = (import ./../../../lib/mkScopes) crossPkgsLinux;

  loom = scopes.callPy3Package ./../../loom { };
in pkgs.dockerTools.buildLayeredImage {
  name = "probcomp/gensql.loom";
  tag = systemWithLinux;
  fromImage = ociImgBase;
  contents = [ loom python ];
  config = {
    Cmd = [ "${python}/bin/python" "-m" "loom.tasks" ];
    Env = [
      "LOOM_STORE=/loom/store"
    ];
  };
}

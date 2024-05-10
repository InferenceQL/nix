{ pkgs,
  nixpkgs,
  opengen,
  system,
}: let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};
  python = crossPkgsLinux.python3;

  base = opengen.packages.${system}.ociImgBase;

  loom = opengen.packages.${systemWithLinux}.loom;
in pkgs.dockerTools.buildLayeredImage {
  name = "probcomp/gensql.loom";
  tag = systemWithLinux;
  fromImage = base;
  contents = [ loom python ];
  config = {
    Cmd = [ "${python}/bin/python" "-m" "loom.tasks" ];
    Env = [
      "LOOM_STORE=/loom/store"
    ];
  };
}

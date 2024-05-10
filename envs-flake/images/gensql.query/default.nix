{ pkgs,
  nixpkgs,
  system,
  opengen,
  gensqlquery,
}: let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};

  base = opengen.packages.${system}.ociImgBase;
  ociBin = gensqlquery.packages.${systemWithLinux}.bin;
in pkgs.dockerTools.buildImage {
  name = "probcomp/gensql.query";
  tag = systemWithLinux;
  fromImage = base;
  copyToRoot = [ ociBin ];
  config = {
    Cmd = [ "${ociBin}/bin/gensql" ];
  };
}

{ pkgs,
  nixpkgs,
  system,
  gensqlquery,
  ociImgBase,
}: let
  # in OCI context, whatever our host platform we want to build same arch but linux
  systemWithLinux = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
  crossPkgsLinux = nixpkgs.legacyPackages.${systemWithLinux};

  ociBin = gensqlquery.packages.${systemWithLinux}.bin;
in pkgs.dockerTools.buildImage {
  name = "probcomp/gensql.query";
  tag = systemWithLinux;
  fromImage = ociImgBase;
  copyToRoot = [ ociBin ];
  config = {
    Cmd = [ "${ociBin}/bin/gensql" ];
  };
}

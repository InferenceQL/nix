pkgs: let
  callPackage = pkgs.newScope (
    pkgs
    // { inherit callPackage; }
  );
  callPy3Package = pkgs.newScope (
    pkgs
    // pkgs.python3Packages
    // { inherit callPackage; }
  );
in {
  inherit callPackage callPy3Package ;
}

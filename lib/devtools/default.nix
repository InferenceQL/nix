_: {
  flake = {
    lib.basicTools = pkgs: with pkgs; [
      coreutils
      curl
      file
      gawk
      git
      gnugrep
      gnused
      which
    ];
  };
}

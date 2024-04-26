# OpenGen/nix

This repo holds Nix flake, modules, packages, and reusable utility Nix language code for use across the OpenGen ecosystem.

## Usage

### Build an artifact

Currently, you can build a package directly like so:

```bash
nix build github.com:OpenGen/nix#ociImgBase
```

### Import utility code

To access the `lib` code exported by this flake, declare this repo as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = ...
    gensqlnix.url = "github:OpenGen/nix";
  };
  outputs = inputs@{ nixpkgs, gensqlnix, ... }: let
    # call some function
    toolbox = gensqlnix.lib.basicTools "aarch64-darwin";
  in {
    ...
  };
};
```

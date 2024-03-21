# InferenceQL/nix

This repo holds Nix flake, modules, packages, and reusable utility Nix language code for use across the InferenceQL ecosystem.

## Usage

### Build an artifact

Currently, you can build a package directly like so:

```bash
nix build github.com:InferenceQL/nix#ociImgBase
```

### Import utility code

To access the `lib` code exported by this flake, declare this repo as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = ...
    iqlnix.url = "github:InferenceQL/nix";
  };
  outputs = inputs@{ nixpkgs, iqlnix , ... }: let
    # call some function
    toolbox = iqlnix.lib.basicTools "aarch64-darwin";
  in {
    ...
  };
};
```

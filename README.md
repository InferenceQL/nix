# OpenGen/nix

This repo holds Nix flake, modules, packages, and reusable utility Nix language code for use across the OpenGen ecosystem.

## Usage

### Build an artifact

Currently, you can build a package directly like so:

```bash
nix build github.com:OpenGen/nix#sppl
```

### Build an OCI image with an environment

OCI images consume these libraries and ones from other OpenGen repos, and are specified in another flake (excepting the `base` oci image):

```bash
nix build github.com:OpenGen/nix#ociImgLoom
```

### Import utility code

To access the `lib` code exported by this flake, declare this repo as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = ...
    opengen.url = "github:OpenGen/nix";
  };
  outputs = inputs@{ nixpkgs, opengen, ... }: let
    # call some function
    toolbox = opengen.lib.basicTools "aarch64-darwin";
  in {
    ...
  };
};
```

## Packages

### `.#sppl`

Python [library by ProbSys](https://github.com/probsys/sppl) packaged for python3.9 .

### `.#loom`

Implementation of [CrossCat in Python](https://github.com/posterior/loom). NOTE: this ONLY builds for `x86_64` architectures and only runs on linux, because it depends on
platform-dependent `distributions`.

Your options are:

```bash
nix build '.#packages.x86_64-linux.loom'                      # same as `.#loom` if that is your OS/arch
nix build './envs-flake#packages.x86_64-darwin.ociImgLoom'
```

If you are running on Mac silicon (`aarch64-darwin`), that OCI image will run but behavior is not defined or supported.

#### `.#loom.morePackages.distributions`

Native library for probability distributions in python used by Loom. NOTE: this ONLY builds for `x86_64` architectures and only runs on linux.

#### `.#loom.morePackages.parsable`
#### `.#loom.morePackages.pymetis`
#### `.#loom.morePackages.goftests`
#### `.#loom.morePackages.tcmalloc`

Other upstream python packages required by Distributions and/or Loom.


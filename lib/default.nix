_: {
  flake.lib = {
    basicTools = import ./devtools;
    mkScopes = import ./mkScopes;
  };
}

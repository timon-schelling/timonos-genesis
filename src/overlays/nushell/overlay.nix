self: super: {
  nushell = self.callPackage (import ./pkg.nix) self;
}

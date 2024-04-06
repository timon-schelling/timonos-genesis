{ config, inputs, ... }:

let
  lib = inputs.nixpkgs.lib;
  libutils = import ./utils.nix { inherit lib; };
  modules = libutils.searchModules [
    ./home
  ];
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit libutils;
    };
    users = lib.mkMerge (lib.mapAttrsToList
      (name: user: {
        ${name} = { ... }: {
          imports = [
            inputs.impermanence.nixosModules.home-manager.impermanence
            ./options/home.nix
          ] ++ modules;
          config = {
            opts = {
              system = config.opts.system;
              inherit name;
              inherit user;
            };
          };
        };
      })
      config.opts.users);
  };
}

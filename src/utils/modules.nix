{ lib, ... }:

let
  modulesRoot = ../modules;
  dirToModulePath = dir: builtins.trace dir (lib.strings.removePrefix "./" (lib.path.removePrefix modulesRoot dir));
  modulePathToEnableOptionConfigPath = path: builtins.trace ("test:" + path) (["modules"] + (builtins.trace (lib.strings.splitString "/" path) (lib.strings.splitString "/" path)));
  enableOptionConfigPathToEnableOption = path:
    if path == [] then
      {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Enables module";
        };
      }
    else
      {
        ${lib.head path} = lib.mkOption {
          type = lib.types.submodule (enableOptionConfigPathToEnableOption (lib.tail path));
        };
      }
  ;

  mkModule = conf: dir: options: config:
    let
      enableOptionConfigPath = modulePathToEnableOptionConfigPath (dirToModulePath dir);
      allOptions = enableOptionConfigPath (enableOptionConfigPathToEnableOption enableOptionConfigPath) // options;
    in
    {
      options = allOptions;
      config = lib.mkIf (lib.attrsets.getAttrFromPath enableOptionConfigPath conf) config;
    }
  ;
in
{
  inherit mkModule;
}

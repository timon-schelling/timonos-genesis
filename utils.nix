{ lib, ... }:

let
  collectDirRecursive = dir: mapAttrs
    (file: type:
      if type == "directory" then listDirRecursive "${dir}/${file}" else type
    )
    (builtins.readDir dir);
  listDirRecursive = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (collectDirRecursive dir));
  searchDirForModules = dir: map
    (file: ./. + "/${file}")
    (filter
      (file: hasSuffix ".nix" file)
      (listDirRecursive dir));
  searchModules = dirs: lib.lists.flatten (map
    (dir: searchDirForModules dir)
    dirs);
in
{
  inherit searchModules;
}

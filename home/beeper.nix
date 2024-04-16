{ pkgs, ... }:

{
  opts.user.persist.state.folders = [
    ".config/Beeper"
  ];

  home.packages = [
    (pkgs.runCommand "beeper-custom"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${pkgs.beeper}/bin/beeper $out/bin/beeper --set ELECTRON_OZONE_PLATFORM_HINT wayland --add-flags "--default-frame"
        cp -r "${pkgs.beeper}/share" "$out/"
      ''
    )
  ];
}

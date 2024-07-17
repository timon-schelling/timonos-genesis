{ pkgs, lib, config, ... }:

{

  platform.system.persist.folders = [
    {
      directory = "/var/cache/regreet";
      user = "greeter";
      group = "greeter";
      mode = "0755";
    }
  ];

  environment.systemPackages = [
    (pkgs.oreo-cursors-plus.override {
      cursorsConf = ''
        custom = color: #1c1c1c, stroke: #eeeeee, stroke-width: 2, stroke-opacity: 1
        sizes = 22
      '';
    })
  ];

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_name = "oreo_custom_cursors";
      };
    };
    cageArgs = [
      "-m"
      "last"
    ];
  };

  # platform.system.persist.folders = [
  #   {
  #     directory = "/var/cache/tuigreet";
  #     user = "greeter";
  #     group = "greeter";
  #     mode = "0755";
  #   }
  # ];

  # services.greetd = {
  #   enable = true;
  #   vt = 2;
  #   settings.default_session = {
  #     command = "${pkgs.greetd.tuigreet}/bin/tuigreet -g '' --time --remember --remember-user-session --asterisks";
  #     user = "greeter";
  #   };
  # };

  # boot.kernelParams = [ "console=tty1" ];

  # systemd.services.greetd = {
  #   serviceConfig = {
  #     Type = "idle";
  #   };
  # };
}

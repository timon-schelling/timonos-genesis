{ pkgs, ... }:

let
  serviceName = "zip.timon.os.System.NvidiaDdcciMonitorFix";
  systemdServiceName = "nvidia-ddcci-monitor-fix";
  serviceStartPkg = pkgs.nu.writeScript "ddcci-load-i2c-devices" ''
    $env.DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket"
    ${pkgs.dbus-listen}/bin/dbus-listen --interface ${serviceName} ${scriptPkg}
  '';
  scriptPkg = pkgs.nu.writeScript "ddcci-load-i2c-devices" ''
    let ddcutil_output = ${pkgs.ddcutil}/bin/ddcutil detect -t
    print $ddcutil_output

    let device_names = $ddcutil_output | lines | where { str contains "/dev/" } | parse --regex ".*/dev/(?P<dev>i2c-.*)" | get dev
    print $device_names

    let target_files = $device_names | each { $"/sys/bus/i2c/devices/($in)/new_device" }
    $target_files | par-each { |it| try { "ddcci 0x37" | save -f $it } }
    print $target_files
  '';
  dbusService = pkgs.writeTextFile rec {
    name = "${serviceName}.service";
    destination = "/share/dbus-1/system-services/${name}";
    text = ''
      [D-BUS Service]
      Name=${serviceName}
      Exec=${serviceStartPkg}
      SystemdService=openrazer-daemon.service
    '';
  };
in
{
  environment.systemPackages = [ pkgs.dbus-listen ];
  services.dbus.packages = [ dbusService ];
  systemd.services."${systemdServiceName}" = {
    description = "Nvidia DDC/CI monitor fix";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "${serviceName}";
      ExecStart = "${serviceStartPkg}";
      Restart = "always";
    };
  };

  # services.udev.extraRules = ''
  #   SUBSYSTEM=="i2c-dev", ACTION=="add",\
  #     ATTR{name}=="NVIDIA i2c adapter*",\
  #     TAG+="ddcci",\
  #     TAG+="systemd",\
  #     ENV{SYSTEMD_WANTS}+="nvidia-fix-ddcci@$kernel.service"
  # '';

  # systemd.services."nvidia-fix-ddcci@" = {
  #   scriptArgs = "%i";
  #   script = ''
  #     echo Trying to attach ddcci to $1
  #     i=0
  #     id=$(echo $1 | cut -d "-" -f 2)
  #     if ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id; then
  #       echo ddcci 0x37 > /sys/bus/i2c/devices/$1/new_device
  #     fi
  #   '';
  #   serviceConfig.Type = "oneshot";
  # };

  # services.udev.extraRules = ''
  #   SUBSYSTEM=="i2c-dev", ACTION=="add", ATTR{name}=="NVIDIA i2c adapter*", TAG+="ddcci", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
  # '';

  # systemd.services."ddcci@" = {
  #   enable = true;
  #   description = "ddcci handler";
  #   after = [ "graphical.target" ];
  #   before = [ "shutdown.target" ];
  #   conflicts = [ "shutdown.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = ''
  #       ${pkgs.bash}/bin/bash -c 'echo Trying to attach ddcci to %i && success=0 && i=0 && id=$(echo %i | cut -d "-" -f 2) && while ((success < 1)) && ((i++ < 5)); do ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id && { success=1 && echo ddcci 0x37 > /sys/bus/i2c/devices/%i/new_device && echo "ddcci attached to %i"; } || sleep 5; done'
  #     '';
  #     Restart = "no";
  #   };
  # };
}

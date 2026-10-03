{ lib, pkgs, config, ... }:

let
  cfg = config.my.nut-watchdog;

  nut-watchdog = pkgs.writeShellApplication {
    name = "nut-watchdog";
    runtimeInputs = [
      config.power.ups.package
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      # upsd replies with ERR DATA-STALE once the driver stops updating it, so
      # a successful upsc query is enough to prove the driver is alive.
      if timeout 10 upsc ${cfg.system} ups.status >/dev/null 2>&1; then
        exit 0
      fi

      now=$(date +%s)
      last=$(cat /run/nut-watchdog/last 2>/dev/null || echo 0)
      if [ "$((now - last))" -lt ${toString cfg.cooldown} ]; then
        exit 0
      fi
      mkdir -p /run/nut-watchdog
      echo "$now" > /run/nut-watchdog/last

      echo "UPS ${cfg.system} unavailable or stale; restarting upsdrv.service"
      systemctl restart upsdrv.service
      sleep 10

      if ! timeout 10 upsc ${cfg.system} ups.status >/dev/null 2>&1; then
        echo "UPS still unavailable; restarting upsd.service"
        systemctl restart upsd.service
      fi
    '';
  };
in
{
  options.my.nut-watchdog = {
    enable = lib.mkEnableOption "watchdog that restarts NUT when the UPS driver stops serving data";

    system = lib.mkOption {
      type = lib.types.str;
      default = "salicru@localhost";
      description = "UPS to poll, in <ups>@<host> form.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "1min";
      description = "How often to poll the UPS.";
    };

    cooldown = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Minimum number of seconds between driver restarts.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nut-watchdog = {
      description = "NUT UPS driver watchdog";
      serviceConfig = {
        Type = "oneshot";
        ConditionPathExists = "!/run/killpower";
        ExecStart = "${nut-watchdog}/bin/nut-watchdog";
      };
    };

    systemd.timers.nut-watchdog = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = cfg.interval;
        AccuracySec = "15s";
      };
    };

    # A hung driver must be killable quickly when the watchdog restarts it.
    systemd.services.upsdrv.serviceConfig.TimeoutStopSec = "15s";
  };
}

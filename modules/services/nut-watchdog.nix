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
      ups_ok() {
        timeout 10 upsc ${cfg.system} ups.status >/dev/null 2>&1
      }

      reset_usb_device() {
        local dev=""

        for candidate in /sys/bus/usb/devices/*; do
          [ -f "$candidate/idVendor" ] || continue
          [ "$(cat "$candidate/idVendor")" = "0665" ] || continue
          [ "$(cat "$candidate/idProduct")" = "5161" ] || continue
          dev=$(basename "$candidate")
          break
        done

        if [ -z "$dev" ]; then
          echo "UPS USB device 0665:5161 not found; cannot reset it"
          return 1
        fi

        echo "Resetting UPS USB device $dev"
        echo "$dev" > /sys/bus/usb/drivers/usb/unbind
        sleep 2
        echo "$dev" > /sys/bus/usb/drivers/usb/bind

        for _ in $(seq 1 20); do
          [ -f "/sys/bus/usb/devices/$dev/idVendor" ] && return 0
          sleep 0.5
        done

        echo "UPS USB device $dev did not reappear after reset"
        return 1
      }

      # upsd replies with ERR DATA-STALE once the driver stops updating it, so
      # a successful upsc query is enough to prove the driver is alive.
      if ups_ok; then
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
      if ! systemctl restart upsdrv.service; then
        echo "upsdrv.service failed to restart"
      fi
      sleep 10

      if ups_ok; then
        exit 0
      fi

      echo "UPS still unavailable; resetting the UPS USB device"
      systemctl stop upsdrv.service || true
      sleep 2
      reset_usb_device || true
      systemctl start upsdrv.service || true
      sleep 15

      if ups_ok; then
        exit 0
      fi

      echo "UPS still unavailable after USB reset; restarting upsd.service"
      systemctl restart upsd.service || true
      sleep 10

      if ! ups_ok; then
        echo "UPS recovery failed; the next watchdog run will retry"
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
      unitConfig = {
        ConditionPathExists = "!/run/killpower";
      };
      serviceConfig = {
        Type = "oneshot";
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

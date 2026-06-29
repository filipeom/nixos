# All the Mods 10 (ATM10) Minecraft Server Module
#
# ATM10 is a ~500-mod NeoForge pack for Minecraft 1.21.1 requiring Java 21.
# This module replaces the vanilla services.minecraft-server for modded play.
#
# ## Updating the modpack
# When a new ATM10 version comes out:
#   1. Update `atm10Version` and `atm10Hash` below
#   2. Stop the server:  systemctl stop minecraft-atm10
#   3. BACKUP your world: cp -r /var/lib/minecraft-atm10/world ~/world-backup
#   4. Remove the init marker: rm /var/lib/minecraft-atm10/.atm10-initialized
#   5. Rebuild & restart: nixos-rebuild switch
#   6. Restore custom configs from backup if needed
#
# ## Memory
# ATM10 needs 8-16 GB RAM. Adjust jvmOpts below.
# The host machine needs extra RAM for the OS (leave 2-4 GB free).

{ config, lib, pkgs, ... }:

let
  cfg = config.services.minecraft-atm10;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # ATM10 server pack — change version & hash for updates
  # Latest: 7.1 from 2026-06-26 (server file ID 8323948, client file ID 8323938)
  atm10Version = "7.1";
  atm10FileId = "8323/948"; # first 4 digits / rest of CurseForge server file ID 8323948

  # Downloaded from CurseForge "Server Files" → mediafilez.forgecdn.net CDN
  # To get the hash, set it to lib.fakeSha256 first, build, then copy the actual
  # hash from the error message.
  atm10ServerPack = pkgs.fetchzip {
    url = "https://mediafilez.forgecdn.net/files/${atm10FileId}/ServerFiles-${atm10Version}.zip";
    hash = "sha256-wMYJVKJpVwYTP1hv3dWFQwxJdvyldB3BXjsAtAKUFxc=";
    stripRoot = false;
  };
in
{
  options.services.minecraft-atm10 = {
    enable = mkEnableOption "All the Mods 10 (ATM10) Minecraft server";

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/minecraft-atm10";
      description = "Directory for server state (world, logs, configs)";
    };

    jvmOpts = mkOption {
      type = types.str;
      default = "-Xms8G -Xmx10G";
      description = "JVM arguments. ATM10 needs at least 8 GB, recommend 10-16 GB.";
      example = "-Xms12G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:+AlwaysPreTouch";
    };

    server-port = mkOption {
      type = types.port;
      default = 25565;
      description = "Port the server listens on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the server port in the firewall";
    };
  };

  config = mkIf cfg.enable {
    # ---- Minecraft system user ----
    users.users.minecraft = {
      isSystemUser = true;
      group = "minecraft";
      home = cfg.stateDir;
      createHome = true;
    };
    users.groups.minecraft = {};

    # ---- Firewall ----
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.server-port ];
      allowedUDPPorts = [ cfg.server-port ];
    };

    # ---- Init service (oneshot, no filesystem restrictions) ----
    # Runs BEFORE the main server to copy files, install NeoForge, etc.
    # Must be separate because ProtectSystem=strict on the main service would
    # block writes to /var/lib even for preStart.
    systemd.services.minecraft-atm10-init = {
      description = "Initialize ATM10 Minecraft server files";
      before = [ "minecraft-atm10.service" ];
      requiredBy = [ "minecraft-atm10.service" ];

      script = ''
        STATE_DIR="${cfg.stateDir}"
        INIT_MARKER="$STATE_DIR/.atm10-initialized"

        if [ -f "$INIT_MARKER" ]; then
          echo "[ATM10] Already initialized, nothing to do."
          exit 0
        fi

        echo "[ATM10] First-time setup: copying server files..."

        # Create state directory and copy ATM10 server pack from nix store
        mkdir -p "$STATE_DIR"
        cp -r ${atm10ServerPack}/* "$STATE_DIR/"

        # Write eula acceptance
        echo "eula=true" > "$STATE_DIR/eula.txt"

        # Write JVM args file used by NeoForge
        cat > "$STATE_DIR/user_jvm_args.txt" << 'JVMARGS'
# Managed by NixOS — edit services.minecraft-atm10.jvmOpts in configuration.nix
${cfg.jvmOpts}
JVMARGS

        # Set server port if server.properties doesn't exist yet
        if [ ! -f "$STATE_DIR/server.properties" ]; then
          cat > "$STATE_DIR/server.properties" << 'PROPS'
# ATM10 server properties — managed by NixOS
server-port=${builtins.toString cfg.server-port}
motd=\u00A7bAll The Mods 10 v7.1 \u00A77| \u00A7dDeclarative Sandbox\n\u00A7a[Reproducible Architecture]
difficulty=normal
gamemode=survival
max-players=20
white-list=false
allow-flight=true
enable-command-block=true
view-distance=10
simulation-distance=8
enable-rcon=true
rcon.port=25575
rcon.password=
PROPS
        fi

        # Install NeoForge server (downloads libraries on first run)
        echo "[ATM10] Installing NeoForge server (this may take a while)..."
        cd "$STATE_DIR"
        export JAVA_HOME="${pkgs.openjdk21}"
        export PATH="$JAVA_HOME/bin:$PATH"

        INSTALLER=$(find . -maxdepth 1 -name "neoforge-installer*.jar" -o -name "forge-*-installer.jar" -o -name "neoforge-*-installer.jar" | head -1)
        if [ -n "$INSTALLER" ]; then
          echo "[ATM10] Found installer: $INSTALLER"
          java -jar "$INSTALLER" --installServer
          echo "[ATM10] NeoForge installed successfully."
        else
          echo "[ATM10] No NeoForge installer found, trying startserver.sh for installation..."
          # Some server packs bundle installation into startserver.sh
          # Run it briefly to trigger NeoForge download, then kill it before server starts
          timeout 120 bash startserver.sh 2>&1 || true
        fi

        # Make scripts executable
        chmod +x "$STATE_DIR"/*.sh 2>/dev/null || true

        echo "[ATM10] Setup complete. Fixing permissions..."
        # Files from the nix store are read-only (0444) — make them writable
        chmod -R u+w "$STATE_DIR"
        chown -R minecraft:minecraft "$STATE_DIR"
        touch "$INIT_MARKER"
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # ---- Main server service ----
    systemd.services.minecraft-atm10 = {
      description = "All the Mods 10 Minecraft Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "minecraft-atm10-init.service" ];
      requires = [ "minecraft-atm10-init.service" ];
      wants = [ "network-online.target" ];

      environment = {
        JAVA_HOME = "${pkgs.openjdk21}";
      };

      path = [ pkgs.openjdk21 ];

      serviceConfig = {
        User = "minecraft";
        Group = "minecraft";
        WorkingDirectory = cfg.stateDir;
        StateDirectory = "minecraft-atm10";

        # Find the NeoForge unix_args.txt dynamically (version-independent)
        ExecStart = pkgs.writeShellScript "atm10-start" ''
          cd ${cfg.stateDir}

          # Find the NeoForge unix_args.txt (handles version changes)
          ARGS_FILE=$(find libraries/net/neoforged/neoforge -name "unix_args.txt" 2>/dev/null | head -1)

          if [ -n "$ARGS_FILE" ]; then
            echo "[ATM10] Starting server with NeoForge args: $ARGS_FILE"
            exec java @user_jvm_args.txt @"$ARGS_FILE" nogui
          else
            echo "[ATM10] No unix_args.txt found — running startserver.sh (JAVA_HOME=$JAVA_HOME)"
            exec bash startserver.sh
          fi
        '';

        # Restart on crash
        Restart = "on-failure";
        RestartSec = "10s";
        StartLimitIntervalSec = "5min";
        StartLimitBurst = 3;

        # ---- Security hardening ----
        # Allow Java (needs writable memory for JIT)
        MemoryDenyWriteExecute = false;

        # Protect the system while allowing the state directory
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        LockPersonality = true;

        # Allow binding to the Minecraft port
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";

        # Raise file descriptor limit (modded servers open many files)
        LimitNOFILE = 65536;
      };
    };
  };
}

# Better MC [FORGE] BMC4 Minecraft Server Module
#
# BMC4 is a ~370-mod Forge pack for Minecraft 1.20.1 requiring Java 17.
# CurseForge project ID: 876781
# Uses ServerPackCreator's start.sh for installation and Forge 47.4.20
#
# ## Updating the modpack
# When a new BMC4 version comes out:
#   1. Update `bmc4Version`, `bmc4FileId`, and `bmc4FileName` below
#   2. Stop the server:  systemctl stop minecraft-bmc4
#   3. BACKUP your world: cp -r /var/lib/minecraft-bmc4/world ~/world-backup
#   4. Remove the init marker: rm /var/lib/minecraft-bmc4/.bmc4-initialized
#   5. Rebuild & restart: nixos-rebuild switch
#   6. Restore custom configs from backup if needed
#
# ## Memory
# BMC4 needs 6-8 GB RAM. Adjust jvmOpts below.
# The host machine needs extra RAM for the OS (leave 2-4 GB free).

{ config, lib, pkgs, ... }:

let
  cfg = config.services.minecraft-bmc4;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # BMC4 server pack — change version, file ID, and filename for updates
  # Latest: v59 (hotfix) from 2026-06-29
  # To find the latest: visit https://www.curseforge.com/minecraft/modpacks/better-mc-forge-bmc4
  # Click the server pack download — the URL reveals the file ID and filename
  bmc4Version = "59";
  bmc4FileId = "8337/928"; # first 4 digits / rest of CurseForge file ID 8337928
  bmc4FileName = "BMC_ServerPack_v59hf.zip";

  # Downloaded from CurseForge "Server Files" → mediafilez.forgecdn.net CDN
  # To get the hash, set it to lib.fakeSha256 first, build, then copy the actual
  # hash from the error message.
  bmc4ServerPack = pkgs.fetchzip {
    url = "https://mediafilez.forgecdn.net/files/${bmc4FileId}/${bmc4FileName}";
    hash = "sha256-pEGp2R09/eWeT0KppnHLrUGCULlbksOE+FUccN3DO7I=";
    stripRoot = false;
  };
in
{
  options.services.minecraft-bmc4 = {
    enable = mkEnableOption "Better MC [FORGE] BMC4 Minecraft server";

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/minecraft-bmc4";
      description = "Directory for server state (world, logs, configs)";
    };

    jvmOpts = mkOption {
      type = types.str;
      default = "-Xms6G -Xmx8G";
      description = "JVM arguments. BMC4 needs at least 6 GB, recommend 6-8 GB.";
      example = "-Xms8G -Xmx8G -XX:+UseG1GC -XX:+AlwaysPreTouch";
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
    # Runs BEFORE the main server to copy files and install Forge via start.sh
    # Must be separate because ProtectSystem=strict on the main service would
    # block writes to /var/lib even for preStart.
    systemd.services.minecraft-bmc4-init = {
      description = "Initialize BMC4 Minecraft server files";
      before = [ "minecraft-bmc4.service" ];
      requiredBy = [ "minecraft-bmc4.service" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      # Need bash, java, gawk (for start.sh), and coreutils (for timeout)
      path = [ pkgs.openjdk17 pkgs.bash pkgs.gawk pkgs.coreutils pkgs.curl pkgs.wget ];

      script = ''
        STATE_DIR="${cfg.stateDir}"
        INIT_MARKER="$STATE_DIR/.bmc4-initialized"

        if [ -f "$INIT_MARKER" ]; then
          echo "[BMC4] Already initialized, nothing to do."
          exit 0
        fi

        echo "[BMC4] First-time setup: copying server files..."

        # Create state directory and copy BMC4 server pack from nix store
        mkdir -p "$STATE_DIR"
        cp -r ${bmc4ServerPack}/* "$STATE_DIR/"

        # Write eula acceptance
        echo "eula=true" > "$STATE_DIR/eula.txt"

        # Write JVM args file
        cat > "$STATE_DIR/user_jvm_args.txt" << 'JVMARGS'
# Managed by NixOS — edit services.minecraft-bmc4.jvmOpts in configuration.nix
${cfg.jvmOpts}
JVMARGS

        # Set server port if server.properties doesn't exist yet
        if [ ! -f "$STATE_DIR/server.properties" ]; then
          cat > "$STATE_DIR/server.properties" << 'PROPS'
# BMC4 server properties — managed by NixOS
server-port=${builtins.toString cfg.server-port}
motd=\u00A7bBetter MC [FORGE] BMC4 v59 \u00A77| \u00A7dDeclarative Sandbox\n\u00A7a[Reproducible Architecture]
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
rcon.password=minecraft
PROPS
        fi

        # Configure ServerPackCreator's start.sh to use NixOS Java
        echo "[BMC4] Configuring variables.txt for NixOS..."
        cd "$STATE_DIR"
        if [ -f "variables.txt" ]; then
          sed -i 's/^SKIP_JAVA_CHECK=.*/SKIP_JAVA_CHECK=true/' variables.txt
          sed -i 's/^WAIT_FOR_USER_INPUT=.*/WAIT_FOR_USER_INPUT=false/' variables.txt
          sed -i 's/^RESTART=.*/RESTART=false/' variables.txt
          # Point JAVA to NixOS Java 17
          sed -i "s|^JAVA=.*|JAVA=${pkgs.openjdk17}/bin/java|" variables.txt
          echo "[BMC4] variables.txt configured."
        fi

        # Install Forge via ServerPackCreator's start.sh
        echo "[BMC4] Running start.sh to install Forge 47.4.20 (this may take a while)..."
        export JAVA_HOME="${pkgs.openjdk17}"
        export PATH="$JAVA_HOME/bin:${pkgs.gawk}/bin:$PATH"
        timeout 300 bash start.sh 2>&1 || echo "[BMC4] start.sh exited with code $?"

        echo "[BMC4] Fixing permissions..."
        chmod -R u+w "$STATE_DIR"
        chown -R minecraft:minecraft "$STATE_DIR"

        # Verify Forge was installed
        if find libraries/net/minecraftforge/forge -name "unix_args.txt" 2>/dev/null | grep -q .; then
          echo "[BMC4] Forge installation verified, marking as initialized."
          touch "$INIT_MARKER"
        else
          echo "[BMC4] ERROR: Forge installation appears to have failed!"
          echo "[BMC4] Check the logs above for errors. Will retry on next restart."
          exit 1
        fi
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # ---- Main server service ----
    systemd.services.minecraft-bmc4 = {
      description = "Better MC [FORGE] BMC4 Minecraft Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "minecraft-bmc4-init.service" ];
      requires = [ "minecraft-bmc4-init.service" ];
      wants = [ "network-online.target" ];

      environment = {
        JAVA_HOME = "${pkgs.openjdk17}";
      };

      path = [ pkgs.openjdk17 pkgs.bash ];

      serviceConfig = {
        User = "minecraft";
        Group = "minecraft";
        WorkingDirectory = cfg.stateDir;
        StateDirectory = "minecraft-bmc4";

        # Start Forge via unix_args.txt, with start.sh as fallback
        ExecStart = pkgs.writeShellScript "bmc4-start" ''
          cd ${cfg.stateDir}

          # Find the Forge unix_args.txt (handles version changes)
          ARGS_FILE=$(find libraries/net/minecraftforge/forge -name "unix_args.txt" 2>/dev/null | head -1)

          if [ -n "$ARGS_FILE" ]; then
            echo "[BMC4] Starting server with Forge args: $ARGS_FILE"
            exec java @user_jvm_args.txt @"$ARGS_FILE" nogui
          elif [ -f "start.sh" ]; then
            echo "[BMC4] No unix_args.txt found — falling back to start.sh"
            exec bash start.sh
          else
            echo "[BMC4] ERROR: Neither unix_args.txt nor start.sh found!"
            exit 1
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

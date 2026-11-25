# Komodo (https://komo.do) — deploys the Docker stacks in github.com/idjoo/stacks
# (from the checkout at ~/documents/stacks on dragon).
#
#   UI:  https://dragon.wyvern-vector.ts.net:9120 (tailnet only, via `tailscale serve`)
#
# Core + Periphery + MongoDB run as plain Docker containers on a private network.
# Periphery connects outbound to Core (Komodo v2), so nothing but the UI is published.
#
# Secrets:
#   secrets/komodo.env          → Core/Mongo env (DB creds, JWT/webhook secrets, init admin)
#   secrets/stacks/<app>.env    → per-stack env, rendered to /var/lib/stacks/secrets/<app>.env
#                                 and referenced by the stack's compose `env_file:`.
# App state lives in /var/lib/stacks/<app>/… (bind-mounted by absolute path).
{
  inputs,
  lib,
  config,
  pkgs,
  rootPath,
  ...
}:
let
  user = "idjo";
  komodoTag = "2.3.4";
  root = "/var/lib/komodo"; # must be the same path inside and outside periphery
  stacksDir = "/var/lib/stacks";
  # git checkout of github.com/idjoo/stacks; Komodo deploys from it in "files on host" mode
  repoDir = "/home/${user}/documents/stacks";
  network = "komodo";

  stackSecrets = [
    "waha"
    "whatsapp-vian"
  ];

  common = {
    autoStart = true;
    extraOptions = [ "--network=${network}" ];
    environmentFiles = [ config.sops.secrets."komodo.env".path ];
  };
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];

    secrets =
      {
        "komodo.env" = {
          sopsFile = rootPath + /secrets/komodo.env;
          format = "dotenv";
          key = "";
        };
      }
      // lib.genAttrs (map (n: "stacks/${n}.env") stackSecrets) (name: {
        sopsFile = rootPath + "/secrets/${name}";
        format = "dotenv";
        key = "";
        # symlink into /run/secrets.d/<gen>/…; both paths are mounted into periphery
        path = "${stacksDir}/secrets/${lib.removePrefix "stacks/" name}";
      });
  };

  systemd.tmpfiles.rules = [
    "d ${root} 0750 root root -"
    "d ${root}/backups 0750 root root -"
    "d ${stacksDir} 0755 root root -"
    "d ${stacksDir}/secrets 0750 root root -"
    # app state (owned by the uid each container runs as)
    "d ${stacksDir}/waha 0755 root root -"
    "d ${stacksDir}/whatsapp-vian 0755 ${user} users -"
    "d ${stacksDir}/bolak-balok 0755 ${user} users -"
    "d ${stacksDir}/survivor-picker 0755 ${user} users -"
  ];

  systemd.services.docker-komodo-periphery.restartTriggers = map (
    n: config.sops.secrets."stacks/${n}.env".sopsFileHash
  ) stackSecrets;

  systemd.services.docker-network-komodo = {
    description = "Docker network for Komodo";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    before = [
      "docker-komodo-mongo.service"
      "docker-komodo-core.service"
      "docker-komodo-periphery.service"
    ];
    requiredBy = [
      "docker-komodo-mongo.service"
      "docker-komodo-core.service"
      "docker-komodo-periphery.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect ${network} >/dev/null 2>&1 \
        || ${pkgs.docker}/bin/docker network create ${network}
    '';
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      komodo-mongo = common // {
        image = "mongo:8.0";
        cmd = [
          "--quiet"
          "--wiredTigerCacheSizeGB"
          "0.25"
        ];
        volumes = [
          "komodo-mongo-data:/data/db"
          "komodo-mongo-config:/data/configdb"
        ];
      };

      komodo-core = common // {
        image = "ghcr.io/moghtech/komodo-core:${komodoTag}";
        dependsOn = [ "komodo-mongo" ];
        ports = [ "127.0.0.1:9120:9120" ];
        environment = {
          TZ = config.time.timeZone;
          KOMODO_DATABASE_ADDRESS = "komodo-mongo:27017";
          KOMODO_HOST = "https://dragon.wyvern-vector.ts.net:9120";
          KOMODO_TITLE = "dragon";
          KOMODO_FIRST_SERVER_NAME = "dragon";
          KOMODO_PERIPHERY_PUBLIC_KEY = "file:/config/keys/periphery.pub";
          KOMODO_LOCAL_AUTH = "true";
          KOMODO_DISABLE_USER_REGISTRATION = "true";
          KOMODO_JWT_TTL = "1-wk";
        };
        volumes = [
          "komodo-keys:/config/keys"
          "${root}/backups:/backups"
          # Resource Sync reads komodo/resources.toml from the checkout
          "${repoDir}/komodo:/syncs/stacks:ro"
        ];
      };

      # periphery needs none of the Core/DB secrets
      komodo-periphery = removeAttrs common [ "environmentFiles" ] // {
        image = "ghcr.io/moghtech/komodo-periphery:${komodoTag}";
        dependsOn = [ "komodo-core" ];
        environment = {
          TZ = config.time.timeZone;
          PERIPHERY_CORE_ADDRESS = "ws://komodo-core:9120";
          PERIPHERY_CONNECT_AS = "dragon";
          PERIPHERY_CORE_PUBLIC_KEYS = "file:/config/keys/core.pub";
          PERIPHERY_ROOT_DIRECTORY = root;
          PERIPHERY_INCLUDE_DISK_MOUNTS = "/etc/hostname";
        };
        volumes = [
          "komodo-keys:/config/keys"
          "/var/run/docker.sock:/var/run/docker.sock"
          "/proc:/proc"
          "${root}:${root}"
          # stack state + rendered secrets (secrets are symlinks into /run/secrets.d)
          "${stacksDir}:${stacksDir}"
          "/run/secrets.d:/run/secrets.d:ro"
          # /run/secrets is a symlink to the current generation; docker resolves it at start,
          # so periphery is restarted whenever a stack secret changes (restartTriggers below)
          "/run/secrets:/run/secrets:ro"
          "${repoDir}:${repoDir}"
        ];
      };
    };
  };
}

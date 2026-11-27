{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.ai;
  browserLibraryPath = lib.makeLibraryPath (
    with pkgs;
    [
      glib
      nspr
      nss
      atk
      at-spi2-atk
      at-spi2-core
      dbus
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libgbm
      expat
      libxcb
      libxkbcommon
      systemd
      alsa-lib
      cairo
      pango
      cups
      fontconfig
    ]
  );
  # T3 downloads an unpatched Chrome headless shell. Its dependency check
  # invokes ldd, which does not use NIX_LD_LIBRARY_PATH on NixOS.
  t3code =
    if pkgs.stdenv.hostPlatform.isLinux then
      pkgs.symlinkJoin {
        name = "t3code-browser-runtime";
        paths = [ pkgs.llm-agents.t3code ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/t3 \
            --prefix LD_LIBRARY_PATH : ${browserLibraryPath}
        '';
      }
    else
      pkgs.llm-agents.t3code;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options.modules.ai = {
    enable = mkEnableOption "AI CLIs (claude-code, codex, dsh, t3code, antigravity-cli, antigravity-acp, opencode, skills, qmd)";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.claude-code
      pkgs.llm-agents.codex
      pkgs.llm-agents.dsh
      t3code
      pkgs.llm-agents.antigravity-cli
      pkgs.antigravity-acp
      pkgs.llm-agents.opencode
      pkgs.llm-agents.skills
      pkgs.llm-agents.qmd
      pkgs.jira-jr
    ];

    # Jira: every agent uses `jr` (sofq/jira-cli) plus its skill, installed
    # with the skills CLI (`skills add sofq/jira-cli -g`).
    sops.secrets."apiKeys/jira" = { };
    sops.secrets."apiKeys/jiraUser" = { };
    sops.templates."jr-config.json" = {
      path = "${config.xdg.configHome}/jr/config.json";
      content = builtins.toJSON {
        default_profile = "default";
        profiles.default = {
          base_url = "https://hyrd.atlassian.net";
          auth = {
            type = "basic";
            username = config.sops.placeholder."apiKeys/jiraUser";
            token = config.sops.placeholder."apiKeys/jira";
          };
        };
      };
    };

    # The self-updating background service starts its downloaded binary directly.
    xdg.configFile."systemd/user/t3code.service.d/browser-runtime.conf" =
      mkIf pkgs.stdenv.hostPlatform.isLinux
        {
          text = ''
            [Service]
            Environment="LD_LIBRARY_PATH=${browserLibraryPath}"
          '';
        };

    home.shellAliases = {
      co = "codex";
      cci = "CLAUDE_CONFIG_DIR=$HOME/.claude-idjo claude";
      ccp = "CLAUDE_CONFIG_DIR=$HOME/.claude-paulsjob claude";
      ccpj = "CLAUDE_CONFIG_DIR=$HOME/.claude-pj claude";
    };

    home.file = builtins.listToAttrs (
      map
        (name: {
          name = ".claude-pj/${name}";
          value.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.claude/${name}";
        })
        [
          "CLAUDE.md"
          "plugins"
          "skills"
        ]
    );

    # Claude writes settings atomically next to the symlink target. A direct
    # link avoids making it create temporary files in the read-only Nix store.
    home.activation.claudePjSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      settings=${lib.escapeShellArg "${config.home.homeDirectory}/.claude-pj/settings.json"}
      if [ ! -e "$settings" ] && [ ! -L "$settings" ]; then
        run mkdir -p "$(dirname "$settings")"
        run ln -s ${lib.escapeShellArg "${config.home.homeDirectory}/.claude/settings.json"} "$settings"
      fi
    '';
  };
}

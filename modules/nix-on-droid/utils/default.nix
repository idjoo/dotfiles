{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.utils;
in
{
  options.modules.utils = {
    enable = mkEnableOption "utils";
  };
  config = mkIf cfg.enable {
    environment.packages = with pkgs; [
      # archive
      unzip
      zip
      openssh

      # nix
      nix-init
      nix-output-monitor
      nurl

      # others
      fd
      git-filter-repo
      jq
      kubectl
      openssl
      p7zip
      ripgrep
      man

      neovim
      git
    ];
  };
}

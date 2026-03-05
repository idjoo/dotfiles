{
  pkgs,
  config,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  programs.nixvim.plugins.avante = {
    enable = true;

    settings = {
      provider = "opencode";

      acp_providers = {
        "opencode" = {
          command = "opencode";
          args = [ "acp" ];
          # env = {
          #   NODE_NO_WARNINGS = "1";
          #   CLI_TITLE = "${outputs.lib.username}";
          #   GOOGLE_APPLICATION_CREDENTIALS = config.sops.secrets."serviceAccounts/ai".path;
          #   GOOGLE_CLOUD_PROJECT = "lv-playground-genai";
          #   GOOGLE_CLOUD_LOCATION = "global";
          # };
          # auth_method = "vertex-ai";
        };
      };
    };
  };
}

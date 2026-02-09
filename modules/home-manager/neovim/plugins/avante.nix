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
      provider = "gemini-cli";

      acp_providers = {
        "gemini-cli" = {
          command = "${pkgs.gemini-cli}/bin/gemini";
          args = [ "--experimental-acp" ];
          env = {
            NODE_NO_WARNINGS = "1";
            CLI_TITLE = "${outputs.lib.username}";
            GOOGLE_APPLICATION_CREDENTIALS = config.sops.secrets."serviceAccounts/ai".path;
            GOOGLE_CLOUD_PROJECT = "lv-playground-genai";
            GOOGLE_CLOUD_LOCATION = "global";
          };
          auth_method = "vertex-ai";
        };
      };
    };
  };
}

{
  pkgs,
  config,
  outputs,
  ...
}:
{
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
            CLI_TITLE = "${outputs.username}";
            GOOGLE_APPLICATION_CREDENTIALS = "${config.home.homeDirectory}/.gemini/sa.json";
            GOOGLE_CLOUD_PROJECT = "lv-playground-genai";
            GOOGLE_CLOUD_LOCATION = "global";
          };
          auth_method = "vertex-ai";
        };
      };
    };
  };
}

{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.qutebrowser;
in
{
  options.modules.qutebrowser = {
    enable = mkEnableOption "qutebrowser";
  };

  config = mkIf cfg.enable {
    programs.qutebrowser = {
      enable = cfg.enable;

      enableDefaultBindings = true;

      loadAutoconfig = false;

      extraConfig = # python
        ''
          config.set("content.javascript.enabled", True)
          config.set("content.javascript.clipboard", "access")
        '';

      quickmarks = {
        google-cloud-platform = "https://console.cloud.google.com";
        google-chat = "https://chat.google.com";
        google-mail = "https://mail.google.com";
      };
    };
  };
}

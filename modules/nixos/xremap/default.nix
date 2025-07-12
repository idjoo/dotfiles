{
  lib,
  config,
  inputs,
  outputs,
  ...
}:
with lib;
let
  cfg = config.modules.xremap;
in
{
  imports = [
    inputs.xremap.nixosModules.default
  ];

  options.modules.xremap = {
    enable = mkEnableOption "xremap";
  };

  config = mkIf cfg.enable {
    services.xremap = {
      enable = cfg.enable;

      userName = outputs.username;
      withX11 = true;

      config = {
        virtual_modifiers = [
          "CapsLock"
        ];

        modmap = [
          {
            name = "global";
            remap = {
              "CapsLock" = {
                alone = [ "Esc" ];
                held = [ "CapsLock" ];
              };
            };
          }

          {
            name = "roblox";
            remap = {
              "Shift_R" = "Shift_L";
            };
            application = {
              only = [ "sober.org.vinegarhq.Sober" ];
            };
          }
        ];

        keymap = [
          {
            name = "vim";
            remap = {
              "CapsLock-k" = "Up";
              "CapsLock-h" = "Left";
              "CapsLock-j" = "Down";
              "CapsLock-l" = "Right";
              "CapsLock-p" = "C-Shift-v";
            };
          }
        ];
      };
    };
  };
}

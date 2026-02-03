{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  programs.nixvim.plugins.wakatime = {
    enable = true;

    lazyLoad = {
      enable = true;
      settings = {
        event = [ "BufReadPost" "BufNewFile" ];
      };
    };
  };

  sops.secrets."apiKeys/wakatime" = { };

  sops.templates.".wakatime.cfg" = {
    content = ''
      [settings]
      api_key = ${config.sops.placeholder."apiKeys/wakatime"}
    '';
    path = "${config.home.homeDirectory}/.wakatime.cfg";
  };
}

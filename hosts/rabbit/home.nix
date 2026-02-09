{
  pkgs,
  outputs,
  ...
}:
{
  imports = [
    outputs.homeModules
  ];

  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];

  modules = {
    nh.enable = true;
  };

  home.stateVersion = "23.11";
}

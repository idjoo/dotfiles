{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];

  home.stateVersion = "23.11";
}

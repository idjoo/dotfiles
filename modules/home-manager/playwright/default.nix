{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.playwright;
  dataDir = "${config.home.homeDirectory}/.playwright";

  # Chromium revision from playwright-driver
  chromiumRevision = pkgs.playwright-driver.passthru.browsersJSON.chromium.revision;

  # Platform-specific executable path
  executablePath =
    if pkgs.stdenv.isDarwin then
      let
        arch = if pkgs.stdenv.hostPlatform.isAarch64 then "mac-arm64" else "mac";
      in
      "${pkgs.playwright-driver.browsers}/chromium-${chromiumRevision}/chrome-${arch}/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
    else
      "${pkgs.playwright-driver.browsers}/chromium-${chromiumRevision}/chrome-linux/chrome";
in
{
  options.modules.playwright = {
    enable = mkEnableOption "playwright";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.playwright-test ];
    # Playwright environment variables
    home.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
      PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = executablePath;
    };

    # Ensure data directory exists
    home.file."${dataDir}/.keep".text = "";
  };
}

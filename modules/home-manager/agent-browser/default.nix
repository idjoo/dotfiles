{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.agent-browser;

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
  options.modules.agent-browser = {
    enable = mkEnableOption "agent-browser";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.llm-agents.agent-browser ];

    # agent-browser uses playwright under the hood
    modules.playwright.enable = mkDefault true;

    # Configure agent-browser to use nix-managed browser via zsh envExtra
    programs.zsh.envExtra = # bash
      ''
        export AGENT_BROWSER_EXECUTABLE_PATH="${executablePath}"
      '';
  };
}

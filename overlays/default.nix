# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    mcp-hub = inputs.mcp-hub.packages.${prev.stdenv.hostPlatform.system}.default;
    mcphub-nvim = inputs.mcphub-nvim.packages.${prev.stdenv.hostPlatform.system}.default;
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # llm-agents.nix overlay - provides pkgs.llm-agents.*
  llm-agents = inputs.llm-agents.overlays.default;
}

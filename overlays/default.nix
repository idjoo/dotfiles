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
    serena = inputs.serena.packages.${prev.stdenv.hostPlatform.system}.default;
    herdr = inputs.herdr.packages.${prev.stdenv.hostPlatform.system}.default;

    # Pin to 13.3.0: flameshot 14 routes all capture through the XDG screenshot
    # portal, and no portal backend here implements it (only -gtk is installed,
    # which dropped Screenshot), so every capture dies on a 30s portal timeout.
    # 13.3.0 grabs X11 directly. The patches are vendored because upstream's
    # load-missing-deps.patch was rewritten for 14's reformatted CMakeLists.
    flameshot = prev.flameshot.overrideAttrs (_old: {
      version = "13.3.0";
      src = final.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        tag = "v13.3.0";
        hash = "sha256-RyoLniRmJRinLUwgmaA4RprYAVHnoPxCP9LyhHfUPe0=";
      };
      patches = [
        ./flameshot/load-missing-deps.patch
        ./flameshot/macos-build.patch
      ];
    });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # llm-agents.nix overlay - provides pkgs.llm-agents.*
  llm-agents = inputs.llm-agents.overlays.shared-nixpkgs;

  # NUR overlay - provides pkgs.nur.*
  nur = inputs.nur.overlays.default;
}

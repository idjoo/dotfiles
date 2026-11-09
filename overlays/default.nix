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
    # Link with lld: GNU ld rejects the debug/eh_frame sections of zig's
    # compiler_rt.o bundled in libghostty-vt ("overlapping FDEs").
    herdr = inputs.herdr.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ final.lld ];
      env = old.env // {
        RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
      };
    });

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

  # llm-agents.nix packages - provides pkgs.llm-agents.*
  # Use the flake's own packages (built against its pinned nixpkgs) instead of
  # overlays.shared-nixpkgs, so they substitute from cache.numtide.com rather
  # than compiling locally against our nixpkgs.
  llm-agents =
    _final: prev:
    let
      upstream = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system};
      # Upstream package omits T3CODE_CLERK_JWT_TEMPLATE, so hasCloudPublicConfig()
      # is false and T3 Connect is hidden. Value from t3code's .env.example.
      # Drop once fixed in llm-agents.nix (builds locally until then).
      t3code = upstream.t3code.override {
        t3code-unwrapped = upstream.t3code.unwrapped.overrideAttrs (old: {
          env = old.env // {
            T3CODE_CLERK_JWT_TEMPLATE = "t3-relay";
          };
        });
      };
    in
    {
      llm-agents = upstream // {
        inherit t3code;
        t3code-desktop = upstream.t3code-desktop.override { inherit t3code; };
      };
    };

  # NUR overlay - provides pkgs.nur.*
  nur = inputs.nur.overlays.default;
}

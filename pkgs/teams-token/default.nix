{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  electron,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "teams-token";
  version = "1.0.0-unstable-2025-12-23";

  src = fetchFromGitHub {
    owner = "fossteams";
    repo = "teams-token";
    rev = "09dad433c98f9d70e23e2f4f3a9645d82fc32b41";
    hash = "sha256-IdOauUG5z+w5H8ppMT51gicz9spG+MPqQJqujNidWlQ=";
  };

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-SBnqkGrtTWEW5tyLH43hOnzV++c3p5/D93tgTK44swI=";
  };

  # The pinned electron 12 npm package only matters for its type definitions;
  # at runtime we use nixpkgs' electron.
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    # Drop devDependencies (typescript, eslint, electron types) from the closure.
    yarn install --offline --frozen-lockfile --production --ignore-scripts
    rm -rf node_modules/electron node_modules/.bin

    mkdir -p $out/lib/teams-token
    cp -r dist node_modules package.json $out/lib/teams-token/

    # Tokens are written to ~/.config/fossteams/, where teams-cli reads them.
    makeWrapper ${lib.getExe electron} $out/bin/teams-token \
      --add-flags $out/lib/teams-token/dist/main.js \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"

    runHook postInstall
  '';

  meta = {
    description = "Electron helper that saves Microsoft Teams tokens for teams-cli";
    homepage = "https://github.com/fossteams/teams-token";
    license = lib.licenses.mit;
    mainProgram = "teams-token";
    platforms = lib.platforms.linux;
  };
})

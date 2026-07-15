{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libcap_ng,
  libGL,
  libdrm,
  libseccomp,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  xorg,
}:
let
  version = "1.18286.0";
  selector = {
    "x86_64-linux" = {
      arch = "amd64";
      hash = "sha256-jzFK0agKq1JxGo6qvAaq5I+zQfCt6koNcmTbXKudBTY=";
    };
    "aarch64-linux" = {
      arch = "arm64";
      hash = "sha256-SCC5iankMzlWtsvq7icy3StJkE+6VAtHKWPIADyAhsc=";
    };
  };
  target = selector.${stdenv.hostPlatform.system} or (throw "claude-desktop: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_${target.arch}.deb";
    inherit (target) hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libcap_ng
    libGL
    libdrm
    libnotify
    libseccomp
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libXtst
  ];

  # Electron dlopen()s some of these at runtime; autoPatchelf's RUNPATH covers
  # the rest.
  runtimeDependencies = [
    (lib.getLib systemd)
  ];

  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  # ponytail: the binary is a self-contained Electron bundle; just relocate it.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib $out/lib
    cp -r usr/share $out/share

    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop

    substituteInPlace $out/share/applications/*.desktop \
      --replace-warn "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    runHook postInstall
  '';

  # wrapGAppsHook + makeWrapper both wrap; let gapps hook decorate our wrapper.
  dontWrapGApps = true;
  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ xdg-utils ]})
  '';

  meta = {
    description = "Desktop application for Claude.ai (Chat, Cowork, and Claude Code)";
    homepage = "https://claude.ai";
    license = lib.licenses.unfree;
    mainProgram = "claude-desktop";
    platforms = builtins.attrNames selector;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

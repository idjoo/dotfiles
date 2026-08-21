{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "clips";
  version = "0.1.296";

  src = fetchurl {
    url = "https://github.com/BuilderIO/agent-native/releases/download/clips-v${version}/Clips_${version}_amd64.AppImage";
    hash = "sha256-yGsOjUS+xmb81GPSD/0d5RXdTDEYD3RaCg4Uf9CH9is=";
  };

  # Extract the SquashFS payload so we can lift out the .desktop entry and icons.
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # The AppImage dlopen()s libayatana-appindicator at runtime for its tray icon
  # but doesn't bundle it; without this the StatusNotifierItem is never created.
  extraPkgs = pkgs: [ pkgs.libayatana-appindicator ];

  # Defensive webkit2gtk defaults for NixOS. NB: the app's window is transparent
  # (Tauri), so it also needs an X compositor running or it paints solid black.
  profile = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export WEBKIT_DISABLE_COMPOSITING_MODE=1
  '';

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/usr/share/applications/Clips.desktop \
      $out/share/applications/Clips.desktop
    substituteInPlace $out/share/applications/Clips.desktop \
      --replace-fail 'Exec=Clips' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
  '';

  meta = {
    description = "Cross-platform tray app for clips (Tauri 2)";
    homepage = "https://clips.agent-native.com";
    downloadPage = "https://github.com/BuilderIO/agent-native/releases";
    license = lib.licenses.unfree;
    mainProgram = "clips";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

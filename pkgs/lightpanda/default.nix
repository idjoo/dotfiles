{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.3.2";
  system = stdenvNoCC.hostPlatform.system;
  selector = {
    "aarch64-linux" = "lightpanda-aarch64-linux";
    "x86_64-linux" = "lightpanda-x86_64-linux";
    "aarch64-darwin" = "lightpanda-aarch64-macos";
    "x86_64-darwin" = "lightpanda-x86_64-macos";
  };
  hashes = {
    "aarch64-linux" = "sha256-kFmdEt5NzmZxwZzX/ljRB4C9mUEZZFA1ifNk2SNyTME=";
    "x86_64-linux" = "sha256-jszImbAKKz/vMa+Jg2oF4evxd8BX/zHdW2mZ+YKaYPY=";
    "aarch64-darwin" = "sha256-cMvhHuUpqfAy54mavepjQbxTUKil5gtkLown12uYDSw=";
    "x86_64-darwin" = "sha256-daUvqsTJIFFrtoO9QtOxwz5oPe+pVuPiT2D1wSEXQaM=";
  };
  asset = selector.${system} or (throw "lightpanda: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "lightpanda";
  inherit version;

  src = fetchurl {
    url = "https://github.com/lightpanda-io/browser/releases/download/${version}/${asset}";
    hash = hashes.${system};
  };

  dontUnpack = true;
  nativeBuildInputs = lib.optional stdenvNoCC.isLinux autoPatchelfHook;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/lightpanda
    runHook postInstall
  '';

  meta = {
    description = "Headless browser designed for AI and automation";
    homepage = "https://lightpanda.io";
    license = lib.licenses.agpl3Only;
    mainProgram = "lightpanda";
    platforms = builtins.attrNames selector;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

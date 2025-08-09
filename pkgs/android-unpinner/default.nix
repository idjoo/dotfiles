{
  python3,
  fetchFromGitHub,
  autoPatchelfHook,
  pkgs,
}:

python3.pkgs.buildPythonApplication {
  pname = "android-unpinner";
  version = "unstable-2025-08-07";
  pyproject = true;

  meta = {
    description = "Remove Certificate Pinning from APKs";
    homepage = "https://github.com/mitmproxy/android-unpinner";
    mainProgram = "android-unpinner";
  };

  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = "android-unpinner";
    rev = "27652d3940dec2c9afd9a78e57bf77a3d79a7d00";
    hash = "sha256-A88GJoS3jYjW5dxxsN+2spu1xM+8OQopZukeKvZGRjE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = [
    python3.pkgs.rich-click
    python3.pkgs.typing-extensions
    pkgs.bionic
  ];

  pythonImportsCheck = [
    "android_unpinner"
  ];

  preBuild = ''
    ${pkgs.tree}/bin/tree .

    mkdir -p build/lib/android_unpinner/vendor
    cp --verbose --no-target-directory --recursive \
      android_unpinner/vendor build/lib/android_unpinner/vendor

    cp --verbose \
      ${pkgs.apksigner}/bin/apksigner \
      build/lib/android_unpinner/vendor/build_tools/linux/apksigner

    addAutoPatchelfSearchPath android_unpinner/vendor
  '';
}

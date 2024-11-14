{
  python3,
  fetchFromGitHub,
  autoPatchelfHook,
  pkgs,
}:

python3.pkgs.buildPythonApplication {
  pname = "android-unpinner";
  version = "unstable-2024-09-02";
  pyproject = true;

  meta = {
    description = "Remove Certificate Pinning from APKs";
    homepage = "https://github.com/mitmproxy/android-unpinner";
    mainProgram = "android-unpinner";
  };

  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = "android-unpinner";
    rev = "2bc31d94c3fe296457e2d7bf2120220de16ca839";
    hash = "sha256-6EHd0CkJ1zlnjWUjDvYaehv3IfqlryKzOsxglPoZiog=";
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

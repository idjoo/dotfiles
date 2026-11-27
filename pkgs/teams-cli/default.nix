{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "teams-cli";
  version = "0.2.3-unstable-2026-04-02";

  # Upstream has no git tags; pin the commit that released v0.2.3.
  src = fetchFromGitHub {
    owner = "fossteams";
    repo = "teams-cli";
    rev = "1f80254abecd728467073bff9c6abb1a4d6b4318";
    hash = "sha256-Qv1eYyG/aMDdkCufo6knounnZJSVH9HlykaibT70MPY=";
  };

  vendorHash = "sha256-FouojAUYgCbE0azCeqgXeaSmfOpsqJ6L5OxcOg+VV6k=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "TUI client for Microsoft Teams";
    homepage = "https://github.com/fossteams/teams-cli";
    license = lib.licenses.mit;
    mainProgram = "teams-cli";
    platforms = lib.platforms.unix;
  };
}

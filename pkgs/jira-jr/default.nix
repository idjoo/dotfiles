{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "jira-jr";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "sofq";
    repo = "jira-cli";
    rev = "v${version}";
    hash = "sha256-U1zoXgXACHLnt+wNZ5J4iMTMTyLmRa21CWHJKLXrO5o=";
  };

  vendorHash = "sha256-Spx4nNZ0LtFHWnbgxVG7RFh8nk+3OxG5u3dD2oMoPJI=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sofq/jira-cli/cmd.Version=${version}"
  ];

  # Tests hit a live Jira mock server and e2e fixtures.
  doCheck = false;

  postInstall = ''
    mv $out/bin/jira-cli $out/bin/jr
  '';

  meta = {
    description = "Agent-friendly Jira Cloud CLI with JSON output";
    homepage = "https://github.com/sofq/jira-cli";
    license = lib.licenses.asl20;
    mainProgram = "jr";
  };
}

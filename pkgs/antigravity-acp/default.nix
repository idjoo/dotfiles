{
  lib,
  buildGoModule,
  antigravity-cli,
}:
buildGoModule {
  pname = "antigravity-acp";
  inherit (antigravity-cli) version;

  src = ./src;

  vendorHash = null;

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.defaultAgyBin=${lib.getExe antigravity-cli}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/antigravity-acp $out/bin
    install -Dm755 "$GOPATH/bin/antigravity-acp" $out/libexec/antigravity-acp/agy_acp_server.par
    ln $out/libexec/antigravity-acp/agy_acp_server.par $out/libexec/antigravity-acp/localharness_external
    ln -s ../libexec/antigravity-acp/agy_acp_server.par $out/bin/agy_acp_server.par

    runHook postInstall
  '';

  meta = {
    description = "Static Go ACP bridge wrapping antigravity-cli (agy acp) for T3 Code";
    homepage = "https://antigravity.google/";
    license = lib.licenses.unfree;
    mainProgram = "agy_acp_server.par";
    inherit (antigravity-cli.meta) platforms;
  };
}

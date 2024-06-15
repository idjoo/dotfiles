{ lib
, buildDotnetGlobalTool
, dotnetCorePackages
}:

buildDotnetGlobalTool {
  pname = "httpgenerator";
  version = "0.5.0";

  nugetSha256 = "sha256-Z8atzrIV3pMX/3wJ/BFR6LFUAniNExnGMhV3WRmJQYQ=";

  meta = {
    description = "Generate .http files from OpenAPI (Swagger) specifications";
    homepage = "https://github.com/christianhelle/httpgenerator";
    changelog = "https://github.com/christianhelle/httpgenerator/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
}

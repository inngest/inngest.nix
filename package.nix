{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:
let
  sources = {
    x86_64-linux = {
      platform = "linux_amd64";
      hash = "sha256-foBi4/dErJXiSuHsRRkZXsGjpOdO20FvtSJfanjzgt4=";
    };
    aarch64-linux = {
      platform = "linux_arm64";
      hash = "sha256-7CllXNkDdRTw9nKB+zLO4HCiGw5JeEFgsiholm//YFY=";
    };
    aarch64-darwin = {
      platform = "darwin_arm64";
      hash = "sha256-TyvdgqnzyfPVszk5zSYm7k1bJR8iu/ywR9bHzvZs2MM=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "inngest";
  version = "1.51.0";

  strictDeps = true;
  src = fetchurl {
    url = "https://github.com/inngest/inngest/releases/download/v${finalAttrs.version}/inngest_${finalAttrs.version}_${source.platform}.tar.gz";
    inherit (source) hash;
  };
  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 inngest $out/bin/inngest
    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "CLI and dev server for Inngest durable workflows";
    homepage = "https://github.com/inngest/inngest";
    changelog = "https://github.com/inngest/inngest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.sspl;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "inngest";
    platforms = builtins.attrNames sources;
  };
})

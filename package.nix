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
      hash = "sha256-1iywR7hHW/jS5szKdXUGiQ+287to5dFeAYgBLFvSzW8=";
    };
    aarch64-linux = {
      platform = "linux_arm64";
      hash = "sha256-UTcNkEP0/l7JdVcXtZ/pWHmEuT2n/i3ePCsotjACr7c=";
    };
    aarch64-darwin = {
      platform = "darwin_arm64";
      hash = "sha256-9g0qkgCloDfz4k/H/BnfRSAFUVENeoHXfu0Dz+h/PpQ=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "inngest";
  version = "1.49.0";

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

{
  description = "Prebuilt Inngest CLI and dev server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      packages = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "inngest";
          };
          inngest = pkgs.callPackage ./package.nix { };
        in
        {
          inherit inngest;
          default = inngest;
        }
      );
    };
}

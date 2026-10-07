# inngest.nix

The [Inngest](https://www.inngest.com/) CLI and dev server for Nix, using official
release binaries.

Supports x86_64 Linux, ARM64 Linux, and Apple Silicon macOS. Requires Nix with
[flakes enabled](https://wiki.nixos.org/wiki/Flakes#Setup).

## Quick start

Run the dev server:

```sh
nix run github:inngest/inngest.nix -- dev
```

Or install the CLI into your user profile:

```sh
nix profile add github:inngest/inngest.nix#inngest
inngest dev
```

Open http://localhost:8288 to access the dev server.

## Add to your flake

Add `inputs.inngest.url`, then include
`inputs.inngest.packages.${system}.default` in your package list. For example,
this `flake.nix` provides a development shell with Inngest:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.inngest.url = "github:inngest/inngest.nix";

  outputs = inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux"; # Or "aarch64-linux" / "aarch64-darwin".
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ inputs.inngest.packages.${system}.default ];
      };
    };
}
```

Start it with `nix develop`, then run `inngest dev`.

The same package can go in NixOS `environment.systemPackages` or Home Manager
`home.packages`. In modules, use `pkgs.stdenv.hostPlatform.system` for `system`
and pass `inputs` through `specialArgs` (NixOS) or `extraSpecialArgs` (Home Manager).

Inngest is SSPL-licensed. This flake handles its license configuration; you do not
need to enable `allowUnfree` in your own configuration.

## Update

To get the latest version packaged by this flake, update your project's lock file:

```sh
nix flake update inngest
```

For a profile installation, use `nix profile upgrade inngest` instead.

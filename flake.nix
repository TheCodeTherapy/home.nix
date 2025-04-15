{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@attrs:
    let
      pkgsFun =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            doCheckByDefault = false;
          };
        };
    in
    {
      nixosConfigurations.threadripper = nixpkgs.lib.nixosSystem rec {
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
        ];

        system = "x86_64-linux";
        pkgs = pkgsFun system;

        specialArgs = {
          inputs = attrs;
        };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = pkgsFun system;
      in
      {
        legacyPackages = pkgs;
        formatter = pkgs.nixfmt-tree;
      }
    ));
}

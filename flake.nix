{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs } @attrs: {
    nixosConfigurations.threadripper = nixpkgs.lib.nixosSystem rec {
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
      ];

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          doCheckByDefault = false;
        };
      };

      system = "x86_64-linux";

      specialArgs = {
        inputs = attrs;
      };
    };
  };
}

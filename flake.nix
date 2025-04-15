{
  description = "A very basic flake";

  inputs = {
    # This commit has kernel v6.14.2 and NVidia driver v570.133.07
    # Check compatibility when updating it
    nixpkgs.url = "github:NixOS/nixpkgs/2631b0b7abcea6e640ce31cd78ea58910d31e650";
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

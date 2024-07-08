{
  description = "Example Virtual Machine Configuration";
  inputs =  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # configuration for builidng qcow2 images
      build-qcow2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./qcow.nix
        ];
      };
    };
  };
}


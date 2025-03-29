{
  description = "Declarative RetroArch setup for Home Manager with libretro cores and secure secrets";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, ... }: {
    #hmModules.retroarch = import ./modules/retroarch.nix;
    hmModules.retroarch = { ... }: {
      imports = [ ./modules/retroarch.nix ];
    };

    # Optional example/test config
    homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [
        ./examples/home.nix
        self.hmModules.retroarch
      ];
    };
  };
}
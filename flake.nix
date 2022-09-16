{
  description = "A minimal Haskell Servant Backend and Purescript frontend example";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, flake-utils, nixpkgs }: {
    overlays.default = final: prev: {
      haskellPackages = prev.haskellPackages.override {
        overrides = hFinal: hPrev: {
          example-api = hFinal.callCabal2nix "example-api" ./api { };
          example-backend = hFinal.callCabal2nix "example-backend" ./backend { };
        };
      };
    };
  } // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
      inherit (pkgs) haskellPackages;
    in
    {
      packages = {
        inherit (haskellPackages)
          example-api
          example-backend;
        default = self.packages.${system}.example-backend;
      };
      checks = self.packages;
      devShells = {
        default = haskellPackages.shellFor {
          packages = _: builtins.attrValues {
            inherit (self.packages.${system})
              example-api
              example-backend
              ;
          };
          withHoogle = true;
          buildInputs = with haskellPackages; [
            haskell-language-server
            ghcid
            cabal-install
          ];
          shellHook = "export PS1='\\e[1;34mdev > \\e[0m'";
        };
      };
    });
}

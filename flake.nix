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
          purescript-client-generator = hFinal.callCabal2nix "purescript-client-generator" ./purescript-client-generator { };
          servant-purescript = hFinal.callCabal2nix "servant-purescript" (final.fetchFromGitHub {
            owner = "eskimor";
            repo = "servant-purescript";
            rev = "6454d5bcb9aa2a5d6e3a3dc935423b67b6f3993c";
            sha256 = "sha256-ZpHB6M5yFYtMpKpM/77yCMlRXmoff0zK7U2cRQ7pLpA=";
          }) {};
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
          example-backend
          purescript-client-generator
          ;
        default = self.packages.${system}.example-backend;
      };
      checks = self.packages;
      devShells = {
        default = haskellPackages.shellFor {
          packages = _: builtins.attrValues {
            inherit (self.packages.${system})
              example-api
              example-backend
              purescript-client-generator
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

{
  description = "A minimal Haskell Servant Backend and Purescript frontend example";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    ps-tools.follows = "purs-nix/ps-tools";
    purs-nix.url = "github:purs-nix/purs-nix/ps-0.15";
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , ps-tools
    , purs-nix
    }: {
      overlays.default = final: prev: {
        haskellPackages = prev.haskellPackages.override {
          overrides = hFinal: hPrev: {
            example-api = hFinal.callCabal2nix "example-api" ./api { };
            example-backend = hFinal.callCabal2nix "example-backend" ./backend { };
            purescript-client-generator = hFinal.callCabal2nix "purescript-client-generator" ./purescript-client-generator { };
            servant-purescript = hFinal.callCabal2nix "servant-purescript"
              (final.fetchFromGitHub {
                owner = "eskimor";
                repo = "servant-purescript";
                rev = "6454d5bcb9aa2a5d6e3a3dc935423b67b6f3993c";
                sha256 = "sha256-ZpHB6M5yFYtMpKpM/77yCMlRXmoff0zK7U2cRQ7pLpA=";
              })
              { };
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

      ps-tools-pkgs = ps-tools.legacyPackages.${system};
      purs-nix-pkgs = purs-nix { inherit system; };
      package = {
        dependencies = with purs-nix-pkgs.ps-pkgs; [
          random
          affjax
          affjax-web
          aff
          bifunctors
          console
          control
          dom-indexed
          effect
          either
          exceptions
          foldable-traversable
          foreign
          fork
          free
          freeap
          functions
          halogen
          halogen-subscriptions
          halogen-vdom
          lazy
          lists
          maybe
          media-types
          newtype
          ordered-collections
          parallel
          prelude
          profunctor
          refs
          simple-json
          strings
          tailrec
          transformers
          tuples
          unfoldable
          unordered-collections
          unsafe-coerce
          unsafe-reference
          web-clipboard
          web-dom
          web-events
          web-file
          web-html
          web-pointerevents
          web-touchevents
          web-uievents
        ];
      };

      ps = purs-nix-pkgs.purs {
        inherit (package) dependencies;
        dir = ./.;
      };

    in
    {
      packages = {
        inherit (haskellPackages)
          example-api
          example-backend
          purescript-client-generator
          ;
        frontend-bundle = ps.modules.Main.bundle { };
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
        ps = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            nodePackages.bower
            (ps.command { })
            ps-tools-pkgs.for-0_15.pulp
            ps-tools-pkgs.for-0_15.purescript-language-server
            purs-nix-pkgs.esbuild
            purs-nix-pkgs.purescript
          ];
          shellHook = ''
            function watch () {
              ln -sf $PWD/main.js $PWD/dist/main.js
              find "$PWD/src" | \
                ${pkgs.entr}/bin/entr -s 'echo bundling; purs-nix bundle'
            }
            function serve () {
              ${pkgs.simple-http-server}/bin/simple-http-server \
                --silent \
                --nocache \
                --index \
                -- "$PWD/dist"
            }
          '';
        };
      };
    });
}

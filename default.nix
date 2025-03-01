{
  withHoogle ? true
}:
let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  nixpkgs = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e8a36cdf57193e56514aa6eeff936159372f0ace";
    sha256 = "1jxdqphacpzkvwpkw67w1222jnmyplzall4n9sdwznyipxz6bqsv";
  };
  config = {
    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = self: super: rec {
          ghc =
            super.ghc // { withPackages = if withHoogle then super.ghc.withHoogle else super.ghc ; };
          ghcWithPackages =
            self.ghc.withPackages;
          # Haskell actually has a broken package called vision
          streamly-extras =
            self.callPackage ./streamly-extras.nix { };
          streamly =
            self.callPackage ./streamly.nix { };
        };
      };
    };
  };
  pkgs = import nixpkgs { inherit config; };
  drv = pkgs.haskellPackages.streamly-extras;
in
  if pkgs.lib.inNixShell
    then
      drv.env.overrideAttrs(attrs:
        { buildInputs =
          with pkgs.haskellPackages;
          [
            cabal-install
            cabal2nix
            ghcid
            hindent
            hlint
            stylish-haskell
          ] ++ [ zlib ] ++ attrs.buildInputs;
        })
        else drv

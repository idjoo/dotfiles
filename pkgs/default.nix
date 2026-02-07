# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  dank-mono-nerdfont = pkgs.callPackage ./dank-mono-nerdfont { inherit pkgs; };
  httpgenerator = pkgs.callPackage ./httpgenerator { };
}

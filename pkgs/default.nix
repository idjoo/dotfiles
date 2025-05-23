# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  android-unpinner = pkgs.callPackage ./android-unpinner { };
  dank-mono-nerdfont = pkgs.callPackage ./dank-mono-nerdfont { inherit pkgs; };
  httpgenerator = pkgs.callPackage ./httpgenerator { };
  mcphub-nvim = pkgs.callPackage ./mcphub-nvim { inherit pkgs; };
}

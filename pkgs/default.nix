# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  antigravity-acp = pkgs.callPackage ./antigravity-acp {
    inherit (pkgs.llm-agents) antigravity-cli;
  };
  claude-desktop = pkgs.callPackage ./claude-desktop { };
  clips = pkgs.callPackage ./clips { };
  dank-mono-nerdfont = pkgs.callPackage ./dank-mono-nerdfont { inherit pkgs; };
  httpgenerator = pkgs.callPackage ./httpgenerator { };
  jira-jr = pkgs.callPackage ./jira-jr { };
  lightpanda = pkgs.callPackage ./lightpanda { };
}

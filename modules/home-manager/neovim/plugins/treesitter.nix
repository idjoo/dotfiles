{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    ensureInstalled = [
      "nix"
      "python"
    ];
  };
}

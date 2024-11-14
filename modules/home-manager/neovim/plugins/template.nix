{ pkgs, ... }:
{
  programs.nixvim.plugins.lazy.plugins = [
    {
      pkg = pkgs.vimPlugins.example;
    }
  ];
}

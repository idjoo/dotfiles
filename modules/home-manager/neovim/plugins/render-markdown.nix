{
  programs.nixvim.plugins.render-markdown = {
    enable = true;

    lazyLoad = {
      enable = true;
      settings = {
        ft = "markdown";
      };
    };
  };
}

{
  programs.nixvim.plugins.fidget = {
    enable = true;

    logger = {
      level = "trace";
    };

    notification = {
      filter = "trace";
      overrideVimNotify = true;
    };
  };
}

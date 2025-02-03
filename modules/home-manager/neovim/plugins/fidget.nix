{
  programs.nixvim.plugins.fidget = {
    enable = true;

    settings = {
      logger = {
        level = "trace";
      };

      notification = {
        filter = "trace";
        override_vim_notify = true;
      };
    };
  };
}

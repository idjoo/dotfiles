{
  programs.nixvim.plugins.smear-cursor = {
    enable = true;

    settings = {
      stiffness = 0.8;
      trailing_stiffness = 0.5;
      distance_stop_animating = 0.5;
      hide_target_hack = false;
      legacy_computing_symbols_support = true;
    };
  };
}

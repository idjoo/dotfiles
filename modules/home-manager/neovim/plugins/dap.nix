{
  programs.nixvim.plugins.dap = {
    enable = true;

    # adapters = {
    #   coreclr = {
    #     executables = "${pkgs.netcoredbg}/bin/netcoredbg";
    #   };
    # };
    #
    # configurations = {
    #   cs = {
    #     name = "launch - netcoredbg";
    #     type = "coreclr";
    #     request = "launch";
    #   };
    # };

    extensions = {
      dap-ui = {
        enable = true;
      };
    };
  };
}

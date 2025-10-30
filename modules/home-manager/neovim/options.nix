{
  programs.nixvim.opts = {
    laststatus = 3;
    showmode = false;

    cursorline = false;

    # indents
    expandtab = true;
    shiftwidth = 2;
    smartindent = true;
    tabstop = 2;
    softtabstop = 2;

    ignorecase = true;
    smartcase = true;

    # numbers
    number = true;
    numberwidth = 1;
    ruler = false;

    signcolumn = "yes";
    splitbelow = true;
    splitright = true;
    termguicolors = true;
    timeoutlen = 300;
    undofile = true;

    updatetime = 250;

    foldmethod = "expr";
    foldexpr = "nvim_treesitter#foldexpr()";
    foldenable = false;

    guicursor = "n-v-c:block,i-ci-ve:ver50,r-cr:hor20,o:hor50";
    wrap = false;
    scrolloff = 10;
    breakindent = true;
    hlsearch = true;
  };
}

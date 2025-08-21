# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  imports = [
    ./atuin
    ./btop
    ./cava
    ./direnv
    ./dunst
    ./eza
    ./firefox
    ./flameshot
    ./fzf
    ./ghostty
    ./git
    ./go
    ./gpg
    ./herbstluftwm
    ./lazygit
    ./neovim
    ./nushell
    ./password-store
    ./polybar
    ./qutebrowser
    ./rofi
    ./ssh
    ./sops
    ./tmux
    ./urxvt
    ./wezterm
    ./zen-browser
    ./zsh
    ./zoxide
  ];
}

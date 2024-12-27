# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  imports = [
    ./btop
    ./cava
    ./direnv
    ./dunst
    ./eza
    ./firefox
    ./flameshot
    ./fzf
    ./git
    ./go
    ./gpg
    ./herbstluftwm
    ./lazygit
    ./neovim
    ./password-store
    ./polybar
    ./rofi
    ./ssh
    ./tmux
    ./urxvt
    ./wezterm
    ./qutebrowser
    ./zsh
  ];
}

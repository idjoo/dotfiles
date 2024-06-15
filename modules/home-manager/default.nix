# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  imports = [
    ./btop
    ./dunst
    ./eza
    ./flameshot
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
    ./wezterm
    ./zsh
  ];
}

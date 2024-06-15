# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  imports = [
    ./eza
    ./dunst
    ./git
    ./gpg
    ./herbstluftwm
    ./lazygit
    ./neovim
    ./password-store
    ./btop
    ./polybar
    ./rofi
    ./tmux
    ./wezterm
    ./zsh
    ./flameshot
  ];
}

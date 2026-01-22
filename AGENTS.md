# Project Context

<note>
This file provides repository context for AI agents working with this codebase.
Behavioral rules are in `~/.config/opencode/AGENTS.md` (loaded automatically).
</note>

<repository-overview>
A Nix flake-based dotfiles repository managing system configurations across multiple platforms: 
NixOS (Linux), nix-darwin (macOS), and nix-on-droid (Android).
</repository-overview>

<common-commands>
  <command description="Rebuild Home Manager only">nh home switch ~/dotfiles</command>
  <command description="Rebuild NixOS (Linux)">nh os switch ~/dotfiles</command>
  <command description="Rebuild macOS">nh darwin switch ~/dotfiles</command>
  <command description="Format Nix files">nix fmt</command>
  <command description="Update flake inputs">nix flake update</command>
  <command description="Stage new files before build (flakes only see git-tracked files)">git add &lt;new-files&gt;</command>
</common-commands>

<architecture>
  <directory-structure>
    <entry path="flake.nix">Entry point: defines inputs, outputs, and all host configurations</entry>
    <entry path="hosts/">Per-machine configurations (ox, horse, tiger, snake, monkey, rabbit)</entry>
    <entry path="hosts/&lt;host&gt;/config.nix">System config (imports modules, sets options)</entry>
    <entry path="hosts/&lt;host&gt;/home.nix">User config for standalone home-manager</entry>
    <entry path="modules/nixos/">NixOS-specific modules (Linux systems)</entry>
    <entry path="modules/darwin/">nix-darwin modules (macOS)</entry>
    <entry path="modules/home-manager/">User-level modules (cross-platform)</entry>
    <entry path="modules/nix-on-droid/">Android-specific modules</entry>
    <entry path="overlays/">Package overlays (additions, modifications, stable-packages)</entry>
    <entry path="pkgs/">Custom package definitions</entry>
  </directory-structure>

  <module-pattern>
    <description>All modules follow an enable pattern with `modules.&lt;name&gt;.enable`</description>
    <example>
      # In host config:
      modules = {
        tailscale.enable = true;
        stylix.enable = true;
      };
    </example>
    <note>
      Modules are imported automatically via `outputs.nixosModules`, `outputs.darwinModules`, 
      or `outputs.homeManagerModules` in each host's config.
    </note>
  </module-pattern>

  <flake-outputs>
    <output name="nixosConfigurations">ox (server), horse (server), tiger (desktop)</output>
    <output name="darwinConfigurations">snake (macOS)</output>
    <output name="nixOnDroidConfigurations">monkey, rabbit (Android)</output>
    <output name="homeConfigurations">Standalone home-manager for each host</output>
  </flake-outputs>

  <overlays description="Three overlay types defined in overlays/default.nix">
    <overlay name="additions">Custom packages from `pkgs/` directory</overlay>
    <overlay name="modifications">Patched/modified upstream packages</overlay>
    <overlay name="stable-packages">Access via `pkgs.stable.*` for stable channel packages</overlay>
  </overlays>
</architecture>

<documentation-reference>
  <man-page name="configuration.nix">NixOS options</man-page>
  <man-page name="darwin-configuration.nix">macOS/nix-darwin options (when on Darwin)</man-page>
  <man-page name="home-configuration.nix">Home Manager options</man-page>
  <man-page name="nixvim">Nixvim options</man-page>
</documentation-reference>

<notes>
  <note>Username is defined globally in `flake.nix` as `outputs.username = "idjo"`</note>
  <note>New files must be `git add`ed before `nix` commands can see them (flake restriction)</note>
  <note>`pkgs.stable.*` provides packages from nixpkgs-stable channel</note>
</notes>

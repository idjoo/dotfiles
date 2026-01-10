{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.lazygit;
in
{
  options.modules.lazygit = {
    enable = mkEnableOption "lazygit";
  };
  config = mkIf cfg.enable {
    programs.lazygit = {
      enable = cfg.enable;

      settings = {
        customCommands = [
          {
            key = "N";
            context = "worktrees";
            description = "Create new worktree from current branch";
            prompts = [
              {
                type = "input";
                title = "Create a new worktree from {{ .CheckedOutBranch.Name }} with what name?";
                key = "Name";
                initialValue = "";
              }
            ];
            command = "git worktree add ../{{ .Form.Name }} {{ .CheckedOutBranch.Name }} -b {{ .Form.Name }}";
          }
          {
            key = "N";
            context = "localBranches";
            description = "Create new worktree from selected branch";
            prompts = [
              {
                type = "input";
                title = "Create a new worktree from {{ .SelectedLocalBranch.Name }} with what name?";
                key = "Name";
                initialValue = "";
              }
            ];
            command = "git worktree add ../{{ .Form.Name }} {{ .SelectedLocalBranch.Name }} -b {{ .Form.Name }}";
          }
          {
            key = "D";
            context = "worktrees";
            description = "Force remove selected worktree";
            prompts = [
              {
                type = "confirm";
                title = "Force Remove Worktree";
                body = "Are you sure you want to remove this worktree and any submodules?";
              }
            ];
            command = "git worktree remove -f {{ .SelectedWorktree.Path | quote }}";
            loadingText = "Removing worktree...";
            output = "log";
          }
          {
            key = "C";
            context = "files";
            description = "AI-powered commit with Claude";
            prompts = [
              {
                type = "confirm";
                title = "AI Commit";
                body = "Generate commit message with Claude?";
              }
            ];
            command = "claude --no-session-persistence --print /commit";
            loadingText = "Generating commit with Claude...";
          }
        ];
      };
    };
  };
}

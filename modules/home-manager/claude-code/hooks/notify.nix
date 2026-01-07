{
  pkgs,
  topic ? "idjo-claude-code",
  server ? "https://ntfy.sh",
}:
let
  script = pkgs.writers.writePython3 "notify" { } ''
    import json
    import subprocess
    import sys


    def send_notification(title, message, tags=""):
        cmd = [
            "${pkgs.ntfy-sh}/bin/ntfy",
            "publish",
            "--server",
            "${server}",
            "--title",
            title,
            "--markdown",
        ]
        if tags:
            cmd.extend(["--tags", tags])
        cmd.extend(["${topic}", message])
        try:
            subprocess.run(cmd, capture_output=True, timeout=5)
        except Exception:
            pass


    def handle_notification(data):
        message = data.get("message", "")
        notification_type = data.get("notification_type", "info")

        type_config = {
            "permission_prompt": ("🔐", "lock"),
            "idle_prompt": ("⏳", "hourglass"),
            "auth_success": ("✅", "white_check_mark"),
            "elicitation_dialog": ("💬", "speech_balloon"),
        }

        emoji, tags = type_config.get(notification_type, ("🤖", "robot"))

        send_notification(
            title=f"{emoji} Claude Code",
            message=message if message else f"_{notification_type}_",
            tags=tags,
        )


    def handle_stop(data):
        session_id = data.get("session_id", "unknown")[:8]

        send_notification(
            title="✅ Claude Code",
            message=f"Session `{session_id}` completed",
            tags="white_check_mark",
        )


    def main():
        try:
            data = json.load(sys.stdin)
        except json.JSONDecodeError:
            print(json.dumps({"continue": True}))
            return

        event = data.get("hook_event_name", "Notification")

        if event == "Stop":
            handle_stop(data)
        else:
            handle_notification(data)

        print(json.dumps({"continue": True}))


    if __name__ == "__main__":
        main()
  '';
in
{
  hooks = [
    {
      type = "command";
      command = script;
      timeout = 10;
    }
  ];
}

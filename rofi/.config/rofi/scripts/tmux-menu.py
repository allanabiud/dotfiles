#!/usr/bin/env python3
import os
import subprocess


def run_command(command):
    """Run a shell command and return the output."""
    try:
        return subprocess.check_output(command, shell=True, text=True).strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command '{command}': {e}")
        return ""


def show_rofi_menu(options, prompt="Tmux"):
    """Display a Rofi menu with the given options."""
    rofi_input = "\n".join(options)
    try:
        result = subprocess.check_output(
            f'echo "{rofi_input}" | rofi -dmenu -i -p "{prompt}"', shell=True, text=True
        ).strip()
        return result
    except subprocess.CalledProcessError:
        return None


def get_tmux_sessions():
    """Retrieve a list of running Tmux sessions."""
    output = run_command("tmux list-sessions -F '#S'")
    return output.splitlines() if output else []


def get_tmuxifier_sessions():
    """Retrieve a list of Tmuxifier session layouts."""
    output = run_command("/home/abiudy/.tmuxifier/bin/tmuxifier list-sessions")
    if not output:
        notify("No Tmuxifier sessions found.")
        return []
    sessions = output.splitlines()
    return [session.strip() for session in sessions if session.strip()]


def notify(message):
    """Send a notification asynchronously."""
    subprocess.Popen(["notify-send", "-t", "1000", "Tmux", message])


def tmuxifier_menu():
    """Display the Tmuxifier submenu."""
    options = ["New Session", "Edit Session", "Load Session", "Delete Session"]
    choice = show_rofi_menu(options, "Tmuxifier")

    if choice == "New Session":
        session_name = show_rofi_menu([], "Enter Session Name:")
        if session_name:
            # Create a new Tmuxifier session
            run_command(
                f"/home/abiudy/.tmuxifier/bin/tmuxifier new-session {session_name}"
            )

            # Construct the full path to the new session file
            session_path = f"/home/abiudy/.tmuxifier/layouts/{session_name}.session.sh"

            # Check if the session file exists
            if os.path.exists(session_path):
                # Launch Neovim in Ghostty directly with the session file
                subprocess.Popen(
                    f'ghostty --class=org.example.editor --x11-instance-name=nvim -e "nvim {session_path}"',
                    shell=True,
                )
                notify(
                    f"New Tmuxifier session '{session_name}' created and opened for editing."
                )
            else:
                notify(f"Failed to create or locate session file for '{session_name}'.")
        else:
            notify("No session name provided.")
    elif choice == "Edit Session":
        # List available Tmuxifier sessions
        sessions = get_tmuxifier_sessions()
        if not sessions:
            notify("No Tmuxifier sessions available to edit.")
            return
        session_name = show_rofi_menu(sessions, "Select Session to Edit:")
        if session_name:
            # Construct the full path to the session file
            session_path = f"/home/abiudy/.tmuxifier/layouts/{session_name}.session.sh"

            # Check if the session file exists
            if os.path.exists(session_path):
                # Launch Neovim in Ghostty directly with the session file
                subprocess.Popen(
                    f'ghostty --class=org.example.editor --x11-instance-name=nvim -e "nvim {session_path}"',
                    shell=True,
                )
                notify(f"Editing Tmuxifier session: {session_name}")
            else:
                notify(f"Session file for '{session_name}' does not exist.")
        else:
            notify("No session selected.")
    elif choice == "Load Session":
        # List available Tmuxifier sessions
        sessions = get_tmuxifier_sessions()
        if not sessions:
            notify("No Tmuxifier sessions available to load.")
            return
        session_name = show_rofi_menu(sessions, "Select Session to Load:")
        if session_name:
            # Run the tmuxifier load-session command in a new Ghostty terminal
            subprocess.Popen(
                f'ghostty --class=org.example.tmux --x11-instance-name=tmux -e "/home/abiudy/.tmuxifier/bin/tmuxifier load-session {session_name}"',
                shell=True,
            )
            notify(f"Loaded Tmuxifier session: {session_name}")
        else:
            notify("No session selected.")
    elif choice == "Delete Session":
        # List available Tmuxifier sessions
        sessions = get_tmuxifier_sessions()
        if not sessions:
            notify("No Tmuxifier sessions available to delete.")
            return

        # Let the user choose which session to delete
        session_name = show_rofi_menu(sessions, "Select Session to Delete:")
        if session_name:
            # Confirm deletion
            confirm = show_rofi_menu(
                ["Yes", "No"],
                f"Are you sure you want to delete session '{session_name}'?",
            )
            if confirm == "Yes":
                # Delete the session using tmuxifier
                run_command(
                    f"/home/abiudy/.tmuxifier/bin/tmuxifier delete-session {session_name}"
                )

                # Delete the corresponding .session.sh file
                session_file = (
                    f"/home/abiudy/.tmuxifier/layouts/{session_name}.session.sh"
                )
                if os.path.exists(session_file):
                    os.remove(session_file)
                    notify(
                        f"Session '{session_name}' and its file '{session_file}' have been deleted."
                    )
                else:
                    notify(f"Session file for '{session_name}' not found.")
            else:
                notify(f"Deletion of session '{session_name}' canceled.")
        else:
            notify("No session selected.")


def main():
    # Retrieve the list of running Tmux sessions
    sessions = get_tmux_sessions()

    # Determine attachable and detachable sessions
    attachable_sessions = [
        session
        for session in sessions
        if not run_command(f"tmux list-clients -t {session} 2>/dev/null")
    ]
    detachable_sessions = [
        session
        for session in sessions
        if run_command(f"tmux list-clients -t {session}")
    ]

    # Base options
    options = ["New Tmux Session", "Tmuxifier"]

    # Add options based on session states
    if attachable_sessions or detachable_sessions or sessions:
        options.append("---")
    if attachable_sessions:
        options.append("Attach to Session")
    if detachable_sessions:
        options.append("Detach from Session")
    if sessions:
        options.append("---")
        options.append("Kill Session")
        options.append("Kill Tmux Server")

    # Show the main Rofi menu
    choice = show_rofi_menu(options)

    if not choice or choice == "---":
        return  # Exit if no choice was made or separator was selected

    if choice == "New Tmux Session":
        session_name = show_rofi_menu([], "Enter Session Name:")
        if session_name:
            subprocess.Popen(
                f'ghostty --class=org.example.tmux --x11-instance-name=tmux -e "tmux new-session -s {session_name}"',
                shell=True,
            )
            notify(f"New Tmux session '{session_name}' created.")
        else:
            notify("No session name provided.")
    elif choice == "Tmuxifier":
        tmuxifier_menu()
    elif choice == "Kill Tmux Server":
        if sessions:
            run_command("tmux kill-server")
            notify("Tmux server killed.")
        else:
            notify("No running Tmux sessions to kill.")
    elif choice == "Kill Session":
        session_name = show_rofi_menu(sessions, "Select Session to Kill:")
        if session_name:
            run_command(f"tmux kill-session -t {session_name}")
            notify(f"Session '{session_name}' killed.")
        else:
            notify("No session selected.")
    elif choice == "Attach to Session":
        if not attachable_sessions:
            notify("No sessions available to attach.")
            return
        session_name = show_rofi_menu(attachable_sessions, "Select Session to Attach:")
        if session_name:
            subprocess.Popen(
                f'ghostty --class=org.example.tmux --x11-instance-name=tmux -e "tmux attach-session -t {session_name}"',
                shell=True,
            )
            notify(f"Attached to session: {session_name}")
        else:
            notify("No session selected.")
    elif choice == "Detach from Session":
        if not detachable_sessions:
            notify("No sessions available to detach.")
            return
        session_name = show_rofi_menu(detachable_sessions, "Select Session to Detach:")
        if session_name:
            run_command(f"tmux detach-client -s {session_name}")
            notify(f"Detached from session: {session_name}")
        else:
            notify("No session selected.")


if __name__ == "__main__":
    main()

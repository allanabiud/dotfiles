# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/DEV/PROJECTS/other_projects/metron/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "metron"; then

  new_window "neovim"
  run_cmd "pipenv shell"
  new_window "django-server"
  select_window 2
  run_cmd "pipenv shell"
  run_cmd "clear"
  new_window "django-shell"
  select_window 3
  run_cmd "pipenv shell"
  run_cmd "clear"

  # Back to the first window.
  select_window 1
  # Wait for the environment to be ready.
  run_cmd "sleep 5"
  # Open neovim.
  run_cmd "nvim"

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session

# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "$HOME/DEV/PROJECTS/my_projects/easy_pay/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "easy_pay"; then

  new_window "neovim"
  run_cmd "pipenv shell"
  new_window "django-server"
  select_window 2
  run_cmd "pipenv shell"
  run_cmd "cd src"
  run_cmd "clear"
  new_window "django-shell"
  select_window 3
  run_cmd "pipenv shell"
  run_cmd "cd src"
  run_cmd "clear"

  # Back to the first window.
  select_window 1
  # Wait for the django-server to start.
  run_cmd "sleep 5"
  # Open neovim.
  run_cmd "nvim"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session

# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/DEV/PROJECTS/my_projects/easy_pay/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "easy_pay"; then

  # Create a new window inline within session layout definition.
  new_window "neovim"
  run_cmd "source venv/bin/activate"
  new_window "django-server"
  select_window 2
  run_cmd "source venv/bin/activate"
  run_cmd "cd src"
  new_window "django-shell"
  select_window 3
  run_cmd "source venv/bin/activate"
  run_cmd "cd src"

  # Back to the first window.
  select_window 1
  run_cmd "nvim"
fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session

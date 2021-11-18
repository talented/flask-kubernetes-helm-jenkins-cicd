#!/bin/bash
set -e

gunicorn -b 0.0.0.0:5000 run:gunicorn_app

# # check if the first passing param is equal to run.py
# if [[ "${1}" = "run.py" ]]; then
#   # execute "python run.py"
#   exec $(which python) "${1}"
# fi

# exec "${@}"
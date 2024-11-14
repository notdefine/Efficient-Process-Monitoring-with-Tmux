#!/bin/bash
function initTmux {
    if [ ! -d "build" ]; then
      echo "'build' directory does not exist. Please create it first.";
      exit 1;
    fi

  : > build/build.log   # Clear file if exists, else create
  : > build/progress.log

  if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Please install it using 'sudo apt-get install tmux'";
    exit 1;
  fi

  tmux kill-session -t buildProcess 2>/dev/null || true
  tmux new-session -d -s buildProcess "tail -f build/progress.log"
  tmux split-window -v "./buildExample.sh run"
  tmux select-pane -t 1

  tmux attach-session -t buildProcess
}

# this is only for simulation of a running task and his output
function simulateTaskWithOutput {
  local text=("Initializing warp drive engines..."
              "Calibrating quantum field arrays "
              "Compiling hyperspace navigation routes..."
              "Decrypting galactic coordinates "
              "Establishing communication link with main hub..."
              "Error: subspace interference detected, rerouting signal..."
              "Launching photon torpedoes"
              "Activating shields at 100% power capacity."
              "Initiating evasive maneuvers...")

  for line in "${text[@]}"; do
    echo "$line"
    sleep 0.3
  done
  echo
}

function run {

  exec > >(tee -a build/build.log)
  exec 2> >(tee -a build/build.log >&2)
  ORIGINAL_DIR=$(pwd)

  function progressMessage {
      echo -e "\e[0m$1\e[0m" >> $ORIGINAL_DIR/build/progress.log
  }
  function progressMessageSuccess {
      echo -e "\e[32m$1\e[0m" >> $ORIGINAL_DIR/build/progress.log
  }
  function progressMessageWarning {
      echo -e "\e[33m$1\e[0m" >> $ORIGINAL_DIR/build/progress.log
  }
  function progressMessageError {
      echo -e "\e[31m$1\e[0m" >> $ORIGINAL_DIR/build/progress.log
  }

  progressMessageWarning "Logs stored in build/build.log";

  sleep 1
  progressMessage "Dummy Task 1: Example Task Running..."
  simulateTaskWithOutput || { progressMessageError "Dummy Task 1 failed"; exit 1; } && progressMessageSuccess "Dummy Task 1 done"

  progressMessage "Dummy Task 2: Example Task Running..."
  simulateTaskWithOutput
  progressMessageError "Dummy Task 2 failed";

  progressMessage "Dummy Task 3: Another Task Running..."
  simulateTaskWithOutput || progressMessageError "Dummy Task 3 failed, will continue"

  sleep 2

  progressMessageSuccess "Finished successful."
}

if [ "$#" -eq 0 ]; then
  initTmux
else
  if [ "$1" == "run" ]; then
    run
  fi
fi

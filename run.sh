#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 version            │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info              │
# ╰──────────────────────╯
# TODO: This is a template runscript.
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# shellcheck disable=SC2034 # Defined-but-not-used caused by set_args
# shellcheck disable=SC2154 # Not-defined caused by set_args
declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}" # TOKEN_DOTFILES_GLOBAL
# ☯ Every file prevents multi-loads itself using this global dict
declare -gA _sourced_files=(["runscript"]="")
# 🖈 If the runscript requires a specific location, set it here
#declare -gr this_location=""
# shellcheck source-path=/home/username/dotfiles/scripts/boilerplate.sh
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@"
# ╭──────────────────────╮
# │ 🛠Configuration      │
# ╰──────────────────────╯
_run_config["versioning"]=0   # {0, 1}
_run_config["log_loads"]=0    # {0, 1}
_run_config["error_frames"]=4 # {1, 2, ...}
# ╭──────────────────────╮
# │ 🗀 Dependencies      │
# ╰──────────────────────╯
# ✔ Ensure versions with satisfy_version
satisfy_version "$dotfiles/scripts/boilerplate.sh" "0.0.0"
# ✔ Source versioned dependencies with load_version
load_version "$dotfiles/scripts/version.sh" "0.0.0"
#load_version "$dotfiles/scripts/assert.sh"
load_version "$dotfiles/scripts/bash_meta.sh" "0.0.0"
#load_version "$dotfiles/scripts/cache.sh"
#load_version "$dotfiles/scripts/error_handling.sh"
load_version "$dotfiles/scripts/fileinteracts.sh" "0.0.0"
#load_version "$dotfiles/scripts/git_utils.sh"
#load_version "$dotfiles/scripts/progress_bar.sh"
#load_version "$dotfiles/scripts/nyx/nyx.sh"
#load_version "$dotfiles/scripts/setargs.sh"
#load_version "$dotfiles/scripts/termcap.sh"
#load_version "$dotfiles/scripts/userinteracts.sh"
#load_version "$dotfiles/scripts/utils.sh"
# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯

declare -r reorder_script="reorder_openings.py"
declare -r temp_dir="./temp/"
declare -r venv_dir="venv"

# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Default command (when no arguments are given)
command_default() {
  declare -r debug=""
  declare -r in1="vsob28/vsob28_original.pgn"
  declare -r in2="vsobX/original.pgn"

  # shellcheck disable=SC2086 # No quoting around $debug
  subcommand combine $debug -- "$in1" "$in2"
}

command_ensure_environment() {
  set_args "--help" "$@"
  eval "$get_args"

  if [[ -d "./${venv_dir}" ]]; then
    echos "Environment exists already"
  else
    command python3 -m venv "$venv_dir"
  fi

  echou "How to use venv:"
  echon "source ./$venv_dir/bin/activate"
  echon "pip3 install chess"
  echon "..."
  echon "deactivate"

  echok "venv ready"
}

command_combine() {
  set_args "--debug --help --" "$@"
  eval "$get_args"

  echoi "Input files:"
  show_variable argv
  ensure_directory "${temp_dir}"

  # The combiner script expects this exact name so we hardcode it
  declare -r input_filename="combined_input.pgn"
  declare -r output_filename="combined_output.pgn"
  command touch -- "./${temp_dir}/${input_filename}"
  command truncate -s 0 -- "./${temp_dir}/${input_filename}"

  # Join files
  declare f=""
  for f in "${argv[@]}"; do
    echoi "In: $(wc -l "$f") lines"
    command cat -- "${f}" >>"./${temp_dir}/${input_filename}"
  done
  echoi "Combined: $(wc -l "./${temp_dir}/${input_filename}")"

  if [[ "$debug" == "true" ]]; then
    command batcat "$temp_dir/$input_filename"
  fi

  # The reordering script uses harcoded input/output file names
  {
    pushd "${temp_dir}" || return 1
    if [[ -f "./$output_filename" ]]; then
      command rm -v -- "./$output_filename"
    fi
    print_and_execute command python3 -- "../${reorder_script}"
    # Sanity check
    if [[ ! -f "./$output_filename" ]]; then
      errchoe "Expected output file $text_user_soft$output_filename$text_normal not found"
      return 1
    fi
    popd || return 1
  }

  echoi "Output: $temp_dir/$output_filename"
  echok "Combined PGNs"
}

# ╭──────────────────────╮
# │ 🖩 Utils             │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖹 Help strings      │
# ╰──────────────────────╯
declare -r ensure_environment_help_string='Create venv if missing'
declare -r combine_help_string='Generate combined PGN
DESCRIPTION
  Uses the TCEC discord #bonus-arena combiner script. It works on text-files so
  is not very safe.

  This command will concat inputs into a temporary file and invoke the reordering
  script on the result.

  Inputs are relative paths (because we prefix ../ from a different directory).
SYNOPSIS
  combine -- ./file1 ./file2
  combine --debug -- ./file1 ./file2
  combine -- ./file1 ./file2 ./file3 ./file4 ...
  combine --help
OPTIONS
  --debug: Enable additional debug printing
  --help: Show this help
'
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# ⌂ Transition to provided command
subcommand "${@}"
# ╭──────────────────────╮
# │ 🕮  Documentation    │
# ╰──────────────────────╯

# vim: shiftwidth=4 indentwidth=4 softtabstop=4

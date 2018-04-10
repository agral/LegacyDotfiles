#!/usr/bin/env bash

SCRIPT_BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_BASEDIR="${SCRIPT_BASEDIR}/Dotfiles"
MANUAL_MERGE_TOOL="meld"

# Prints out the diff status of two files.
# Usage: Install source target
# Params: source - a file from this repository, target - where to install it.

function Install
{
  if [ "${#}" -ne 2 ]; then
    >&2 printf "Fatal: %s\n%s %d %s\n%s" "wrong invocation of Install method." \
        "Expected exactly two arguments, but" "${#}" "have been provided." \
        "Aborting."
    exit 1
  fi

  printed_name="$(basename "${1}")"
  printf "Checking: %s\n" "${printed_name}"

  if [ ! -f "${1}" ]; then
    >&2 printf "%s \"%s\" %s\n%s\n%s\n" \
        "Fatal: source file" "${1}" "does not exist." \
        "Please fix the install script." \
        "Aborting."
    exit 1
  fi

  TARGET_PARENT_DIR="$(basename "${2}")"

  if [ ! -f "${2}" ]; then
    printf "  -> Target not found, installing... "
    mkdir -p "${TARGET_PARENT_DIR}" && cp "${1}" "${2}"
    if [ "${?}" -eq 0 ]; then
      printf "done.\n"
    else
      printf "failed.\n"
    fi
  else
    if cmp "${1}" "${2}" >/dev/null 2>&1; then
      printf "  -> Files are identical.\n"
    else
      printf "  -> Files differ, invoking %s tool...\n" "${MANUAL_MERGE_TOOL}"
      printf -v cmd "%s %s %s" "${MANUAL_MERGE_TOOL}" "${1}" "${2}"
      eval "${cmd}"
    fi
  fi
}

printf "%s:\n" "1. Shell-related dotfiles"
SHRC_SRCDIR="${DOTFILES_BASEDIR}/shrc"
SHRC_TARDIR="${HOME}/.config/shrc"
Install "${SHRC_SRCDIR}/bash_profile" "${HOME}/.bash_profile"
Install "${SHRC_SRCDIR}/bashrc" "${HOME}/.bashrc"
Install "${SHRC_SRCDIR}/common.shrc" "${SHRC_TARDIR}/common.shrc"
Install "${SHRC_SRCDIR}/package_manager.shrc" "${SHRC_TARDIR}/package_manager.shrc"
Install "${SHRC_SRCDIR}/machine_specific.shrc" "${SHRC_TARDIR}/machine_specific.shrc"

printf "\n%s:\n" "2. Openbox config files"
OPENBOX_SRCDIR="${DOTFILES_BASEDIR}/openbox"
OPENBOX_TARDIR="${HOME}/.config/openbox"
Install "${OPENBOX_SRCDIR}/autostart" "${OPENBOX_TARDIR}/autostart"
Install "${OPENBOX_SRCDIR}/environment" "${OPENBOX_TARDIR}/environment"
Install "${OPENBOX_SRCDIR}/menu.xml" "${OPENBOX_TARDIR}/menu.xml"
Install "${OPENBOX_SRCDIR}/rc.xml" "${OPENBOX_TARDIR}/rc.xml"

printf "\n%s:\n" "3. Other config files"
Install "${DOTFILES_BASEDIR}/tmux.conf" "${HOME}/.tmux.conf"

printf "=== Done. ===\n"

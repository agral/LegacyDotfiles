#!/usr/bin/env bash

# Name:          Install
# Description:   Installs the dotfiles intelligently by creating the parent directory structure
#                and allowing for manual application of individual changes in case of collision.
# Options:       None
# Created on:    11-10-2017
# Last modified: 19-06-2019
# Author:        Adam Graliński (adam@gralin.ski)
# License:       CC0


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

counter=1
printf "%d. %s:\n" "${counter}" "Shell-related dotfiles"
SHRC_SRCDIR="${DOTFILES_BASEDIR}/shrc"
SHRC_TARDIR="${HOME}/.config/shrc"
Install "${SHRC_SRCDIR}/bash_profile" "${HOME}/.bash_profile"
Install "${SHRC_SRCDIR}/bashrc" "${HOME}/.bashrc"
Install "${SHRC_SRCDIR}/global_variables.shrc" "${SHRC_TARDIR}/global_variables.shrc"
Install "${SHRC_SRCDIR}/common.shrc" "${SHRC_TARDIR}/common.shrc"
Install "${SHRC_SRCDIR}/package_manager.shrc" "${SHRC_TARDIR}/package_manager.shrc"
Install "${SHRC_SRCDIR}/machine_specific.shrc" "${SHRC_TARDIR}/machine_specific.shrc"

counter=$((counter + 1))
printf "\n%d. %s:\n" "${counter}" "Custom shell scripts"
SCRIPTS_SRCDIR="${DOTFILES_BASEDIR}/bin"
SCRIPTS_TARDIR="${HOME}/.local/bin"

# Enables nullglob, which makes the for loop ignore empty directory.
# Without nullglob enabled the for loop executes once with filename=* iff source directory is empty.
shopt -s nullglob
for file in "${SCRIPTS_SRCDIR}"/* ; do
  script_name="$(basename "${file}")"
  Install "${SCRIPTS_SRCDIR}/${script_name}" "${SCRIPTS_TARDIR}/${script_name}"
done
shopt -u nullglob # restores nullglob back to its default (unset) state

counter=$(($counter + 1))
printf "\n%d. %s:\n" "${counter}" "Openbox config files"
OPENBOX_SRCDIR="${DOTFILES_BASEDIR}/openbox"
OPENBOX_TARDIR="${HOME}/.config/openbox"
Install "${OPENBOX_SRCDIR}/autostart" "${OPENBOX_TARDIR}/autostart"
Install "${OPENBOX_SRCDIR}/environment" "${OPENBOX_TARDIR}/environment"
Install "${OPENBOX_SRCDIR}/menu.xml" "${OPENBOX_TARDIR}/menu.xml"
Install "${OPENBOX_SRCDIR}/rc.xml" "${OPENBOX_TARDIR}/rc.xml"

counter=$(($counter + 1))
printf "\n%d. %s:\n" "${counter}" "mpd/ncmpcpp config files"
MPD_SRCDIR="${DOTFILES_BASEDIR}/mpd"
MPD_TARDIR="${HOME}/.config/mpd"
Install "${MPD_SRCDIR}/mpd.conf" "${MPD_TARDIR}/mpd.conf"
Install "${MPD_SRCDIR}/mpd_incoming.conf" "${MPD_TARDIR}/mpd_incoming/mpd_incoming.conf"
Install "${MPD_SRCDIR}/mpd_podcast.conf" "${MPD_TARDIR}/mpd_podcast/mpd_podcast.conf"
NCMPCPP_SRCDIR="${DOTFILES_BASEDIR}/ncmpcpp"
NCMPCPP_TARDIR="${HOME}/.ncmpcpp"
Install "${NCMPCPP_SRCDIR}/config" "${NCMPCPP_TARDIR}/config"
Install "${NCMPCPP_SRCDIR}/incoming_config" "${NCMPCPP_TARDIR}/incoming_config"
Install "${NCMPCPP_SRCDIR}/podcast_config" "${NCMPCPP_TARDIR}/podcast_config"

counter=$(($counter + 1))
printf "\n%d. %s:\n" "${counter}" "Other config files"
Install "${DOTFILES_BASEDIR}/gitconfig" "${HOME}/.gitconfig"
Install "${DOTFILES_BASEDIR}/tint2rc" "${HOME}/.config/tint2/tint2rc"
Install "${DOTFILES_BASEDIR}/tmux.conf" "${HOME}/.tmux.conf"
Install "${DOTFILES_BASEDIR}/xinitrc" "${HOME}/.xinitrc"
Install "${DOTFILES_BASEDIR}/Xresources" "${HOME}/.Xresources"

counter="$(($counter + 1))"
printf "\n%d. %s:\n" "${counter}" "Vim config files"
Install "${DOTFILES_BASEDIR}/vimrc" "${HOME}/.vimrc"

printf "=== Done. ===\n"

#!/usr/bin/env bash

# Name:          VerifyHrAnswer
# Description:   Executes an answer to a HackerRank's challenge against all the testcases
#                associated with it.
# Options:       None, the script needs to be run from the challenge's root directory.
#                (e.g. /path/to/hacker/rank/dir/Practice/Algorithms/Search/CountLuck)
# Created on:    20.10.2019
# Last modified: 20.10.2019
# Author:        Adam Graliński (adam@gralin.ski)
# License:       MIT

DIR_ORIGIN="$(pwd)"
DIR_TESTCASES_IN="testcases/input"
DIR_TESTCASES_OUT="testcases/output"
PROGRAM="bin/exe"

abort() {
  >&2 echo "Aborting."
  exit 1
}

# Verifies that the testcases directory exists and that the program exists:
if [ ! -d "${DIR_TESTCASES_IN}" ] || [ ! -d "${DIR_TESTCASES_OUT}" ]; then
  >&2 echo "Error: testcases have not been found at ${DIR_TESTCASES_IN}, ${DIR_TESTCASES_OUT}."
  abort
fi
if [ ! -f "${DIR_ORIGIN}/${PROGRAM}" ]; then
  >&2 echo "Error: the compiled program has not been found at ${PROGRAM}."
  abort
fi

find "${DIR_TESTCASES_IN}" -type f -name "*.txt" | sort | while read testcase; do
  echo "Processing ${testcase}"
  valid_output_file="${testcase//input/output}"
  diff "${valid_output_file}" <(./${PROGRAM} <${testcase})
  result="${?}"
  if [ "${result}" -eq 0 ]; then
    echo "OK (passed)"
  else
    echo "FAILED"
  fi
  echo
done

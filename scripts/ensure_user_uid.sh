#!/usr/bin/env bash

set -euxo pipefail

# shellcheck disable=SC2312
if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

old_user="${1}"
old_uid=$(id -u "${old_user}")
new_uid="${2}"

if [[ "${old_uid}" == "${new_uid}" ]]; then
  echo "User ${old_user} already has uid as ${new_uid}"
  exit 0
fi

function get_user_name() {
  id -nu "${1}"
}

function check_process_for_uid() {
  local user_name
  user_name=$(get_user_name "${1}")
  # shellcheck disable=SC2009
  if ps -ef | grep "^${user_name} "; then
    echo "Above is the list of processes running for user ${user_name}, please log out."
    return 1
  fi
}

check_process_for_uid "${old_uid}"

function relocate_user() {
  local old=$1
  local name
  name=$(get_user_name "${old}")
  local new=$2

  # shellcheck disable=SC2312
  if [[ $(id -ng "${old}") != "${name}" ]]; then
    echo "This script only support relocating users with group that matches the uid and user name."
    exit 1
  fi

  # shellcheck disable=SC2312
  if [[ $(getent group "${name}" | wc -l) != "1" ]]; then
    echo "This script only support relocating users with group that have only the same user inside."
    exit 1
  fi

  check_process_for_uid "${old}"

  id "${name}"

  groupmod -g "${new}" "${name}"
  usermod -u "${new}" -g "${new}" "${name}"

  id "${name}"

  local find_args=(/ -type d '('
    # https://stackoverflow.com/a/57491476/12156188
    -path /proc
    # Exclude known docker data dirs
    -o -path /var/lib/docker
    ')' -prune)

  find "${find_args[@]}" -o -group "${old}" -user "${old}" -print0 | xargs -0 --no-run-if-empty chown -ch "${name}:${name}"
  find "${find_args[@]}" -o -group "${old}" -print0 | xargs -0 --no-run-if-empty chgrp -ch "${name}"
  find "${find_args[@]}" -o -user "${old}" -print0 | xargs -0 --no-run-if-empty chown -ch "${name}"

  echo "Finished moving."
}

if existing_user=$(get_user_name "${new_uid}"); then
  next_uid=$(cat /etc/group /etc/passwd | cut -d ":" -f 3 | grep "^1...$" | sort -n | tail -n 1 | awk '{ print $1+1 }')
  echo "First moving existing user ${existing_user} to the next available UID/GID is ${next_uid}"

  relocate_user "${new_uid}" "${next_uid}"
fi

echo "Moving now..."
relocate_user "${old_uid}" "${new_uid}"

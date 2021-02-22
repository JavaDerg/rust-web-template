#!/bin/sh

__validate() {
  [[ "$1" =~ ^[a-z]([a-z0-9]|-+[a-z0-9])*$ ]] && return 0 || return 1
}

name="${PWD##*/}" # no clue why this works

__read_project_name() {
  __validate "$name" && display="($name) " || name="" display=""
  while :
  do
    read -rp "Enter a project name: $display" tmp_name
    if [[ -z "$tmp_name" ]] && [[ -z "$name" ]]; then
      >&2 echo "Only names that match '^[a-z]([a-z0-9]|-+[a-z0-9])*$' are allowed."
    else
      [[ -z "$tmp_name" ]] || name="$tmp_name"
      break
    fi
  done
}

__read_project_name
echo "$name"

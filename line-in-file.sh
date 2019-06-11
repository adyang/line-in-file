#!/bin/bash

line_in_file() {
  local line="$1"
  local file="$2"
  grep -qF -- "${line}" "${file}" || echo "${line}" >> "${file}" 
}

escape_forward_slash() {
  sed 's|/|\\/|g' <<< "$1"
}

upsert_line_in_file() {
  local regex="$1"
  local line="$2"
  local file="$3"
  if grep -qE -- "${regex}" "${file}"; then
    local escaped_regex="$(escape_forward_slash "${regex}")"
    sed -E -i '' "/${escaped_regex}/"$'c\\\n'"${line}"$'\n' "${file}"
  else
    echo "${line}" >> "${file}" 
  fi
}


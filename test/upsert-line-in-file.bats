#!/usr/bin/env bats

setup() {
  test_file="$(mktemp)"
  local contents=(
    'line1'
    'line two'
    'export PATH=${PATH}:/path/to/line-3.0/bin'
  )
  printf '%s\n' "${contents[@]}" > "${test_file}"
}

teardown() {
  rm "${test_file}"
}

source ./line-in-file.sh

@test "new line exact match" {
  run upsert_line_in_file 'this is a new line' 'this is a new line' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'export PATH=${PATH}:/path/to/line-3.0/bin' ]
  [ "${lines[3]}" == 'this is a new line' ]
}

@test "new line regex match" {
  run upsert_line_in_file '.* new line$' 'this is a new line' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'export PATH=${PATH}:/path/to/line-3.0/bin' ]
  [ "${lines[3]}" == 'this is a new line' ]
}

@test "new line regex match on special characters" {
  run upsert_line_in_file '^export PATH=${PATH}:/path/to/lib-.*/bin' 'export PATH=${PATH}:/path/to/lib-1.0/bin' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'export PATH=${PATH}:/path/to/line-3.0/bin' ]
  [ "${lines[3]}" == 'export PATH=${PATH}:/path/to/lib-1.0/bin' ]
}

@test "old line regex replacement" {
  run upsert_line_in_file '^line two' 'line two changed' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two changed' ]
  [ "${lines[2]}" == 'export PATH=${PATH}:/path/to/line-3.0/bin' ]
}


@test "old line regex replacement on special characters needs escaping" {
  run upsert_line_in_file '^export PATH=\${PATH}:/path/to/line-.*/bin' 'export PATH=${PATH}:/path/to/line-changed-3.1.3/bin' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'export PATH=${PATH}:/path/to/line-changed-3.1.3/bin' ]
}


#!/usr/bin/env bats

setup() {
  test_file="$(mktemp)"
  local contents=(
    'line1'
    'line two'
    'line ^th$ee'
  )
  printf '%s\n' "${contents[@]}" > "${test_file}"
}

teardown() {
  rm "${test_file}"
}

source ./line-in-file.sh

@test "new line" {
  run line_in_file 'this is a new line' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'line ^th$ee' ]
  [ "${lines[3]}" == 'this is a new line' ]
}

@test "old line" {
  run line_in_file 'line two' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'line ^th$ee' ]
}

@test "new line with special characters" {
  run line_in_file 'th!$ |s n#w l*n@' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'line ^th$ee' ]
  [ "${lines[3]}" == 'th!$ |s n#w l*n@' ]
}

@test "old line with special characters" {
  run line_in_file 'line ^th$ee' "${test_file}"

  [ "$status" -eq 0 ]
  run cat "${test_file}"
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'line1' ]
  [ "${lines[1]}" == 'line two' ]
  [ "${lines[2]}" == 'line ^th$ee' ]
}


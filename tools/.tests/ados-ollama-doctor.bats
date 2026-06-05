#!/usr/bin/env bats
# Smoke tests for tools/ados-ollama-doctor

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
  DOCTOR="${REPO_ROOT}/tools/ados-ollama-doctor"
}

@test "doctor passes a bash syntax check" {
  bash -n "${DOCTOR}"
}

@test "doctor --help prints usage and exits 0" {
  run "${DOCTOR}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}

@test "doctor --version prints the name and version" {
  run "${DOCTOR}" --version
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"ados-ollama-doctor"* ]]
}

@test "doctor rejects unknown options" {
  run "${DOCTOR}" --bogus
  [ "${status}" -eq 2 ]
}

@test "doctor prints both the runtime and dev-tools sections" {
  # Exit status varies with host state; only the report shape is asserted.
  run "${DOCTOR}"
  [[ "${output}" == *"Runtime"* ]]
  [[ "${output}" == *"Dev tools"* ]]
}

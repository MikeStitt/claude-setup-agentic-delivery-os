#!/usr/bin/env bats
# Tests for scripts/install-ados.sh

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
  SCRIPT="${REPO_ROOT}/scripts/install-ados.sh"
  ADOS="${REPO_ROOT}/../agentic-delivery-os"
}

@test "install-ados.sh passes a bash syntax check" {
  bash -n "${SCRIPT}"
}

@test "install-ados.sh --help prints usage and exits 0" {
  run "${SCRIPT}" --help
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Usage:"* ]]
}

@test "install-ados.sh --version prints name and version" {
  run "${SCRIPT}" --version
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"install-ados"* ]]
}

@test "install-ados.sh rejects unknown options" {
  run "${SCRIPT}" --bogus
  [ "${status}" -eq 2 ]
}

@test "install-ados.sh installs agents project-local + provenance (idempotent)" {
  [ -d "${ADOS}/.opencode/agent" ] || skip "ADOS checkout not available"
  tmp="$(mktemp -d)"
  git -C "${tmp}" init -q

  run "${SCRIPT}" --target "${tmp}" --ados-repo "${ADOS}"
  [ "${status}" -eq 0 ]
  [ -f "${tmp}/.opencode/agent/pm.md" ]
  [ -f "${tmp}/.opencode/command/plan-change.md" ]
  [ -f "${tmp}/.opencode/ados-provenance.txt" ]

  # Second run converges (no agent re-copy reported).
  run "${SCRIPT}" --target "${tmp}" --ados-repo "${ADOS}"
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"copy agent/pm.md"* ]]

  rm -rf "${tmp}"
}

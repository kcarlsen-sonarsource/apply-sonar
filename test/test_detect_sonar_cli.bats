#!/usr/bin/env bats
# Tests for detect_sonar_cli function

load helpers/test_helper
load helpers/mock_config

@test "detect_sonar_cli: finds sonar on PATH" {
    export MOCK_SONAR_API_SUPPORTED=true
    detect_sonar_cli

    [[ -n "$SONAR_CLI" ]]
}

@test "detect_sonar_cli: sets SONAR_CLI_HAS_API=true when api supported" {
    export MOCK_SONAR_API_SUPPORTED=true
    detect_sonar_cli

    [[ "$SONAR_CLI_HAS_API" = "true" ]]
}

@test "detect_sonar_cli: sets SONAR_CLI_HAS_API=false when api not supported" {
    export MOCK_SONAR_API_SUPPORTED=false
    detect_sonar_cli

    [[ "$SONAR_CLI_HAS_API" = "false" ]]
}

@test "detect_sonar_cli: finds sonar at local bin path" {
    # Remove test/bin from PATH for this test
    local orig_path="$PATH"
    PATH="$(echo "$PATH" | sed "s|${TEST_DIR}/bin:||")"

    # Create the local bin
    mkdir -p "$HOME/.local/share/sonarqube-cli/bin"
    cp "${TEST_DIR}/bin/sonar" "$HOME/.local/share/sonarqube-cli/bin/sonar"
    chmod +x "$HOME/.local/share/sonarqube-cli/bin/sonar"

    detect_sonar_cli

    [[ -n "$SONAR_CLI" ]]
    [[ "$SONAR_CLI" = "$HOME/.local/share/sonarqube-cli/bin/sonar" ]]

    PATH="$orig_path"
}

@test "detect_sonar_cli: returns 1 when sonar not found" {
    # Remove test/bin from PATH
    local orig_path="$PATH"
    PATH="$(echo "$PATH" | sed "s|${TEST_DIR}/bin:||")"

    # detect_sonar_cli should return 1 when sonar is not found
    local rc=0
    detect_sonar_cli || rc=$?
    [[ "$rc" -ne 0 ]]

    PATH="$orig_path"
}

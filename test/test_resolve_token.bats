#!/usr/bin/env bats
# Tests for resolve_token function

load helpers/test_helper
load helpers/mock_config

@test "resolve_token: uses --token when provided and valid" {
    TOKEN="squ_provided_token"
    export MOCK_CURL_AUTH_VALID=true

    run resolve_token

    assert_success
    [[ "$TOKEN" = "squ_provided_token" ]]
}

@test "resolve_token: uses SONAR_TOKEN when no --token" {
    TOKEN=""
    export SONAR_TOKEN="squ_env_token"
    export MOCK_CURL_AUTH_VALID=true

    resolve_token

    [[ "$TOKEN" = "squ_env_token" ]]
}

@test "resolve_token: uses SONARQUBE_CLI_TOKEN when no --token" {
    TOKEN=""
    export SONARQUBE_CLI_TOKEN="squ_cli_env_token"
    export MOCK_CURL_AUTH_VALID=true

    resolve_token

    [[ "$TOKEN" = "squ_cli_env_token" ]]
}

@test "resolve_token: prefers --token over env vars" {
    TOKEN="squ_flag_token"
    export SONAR_TOKEN="squ_env_token"
    export MOCK_CURL_AUTH_VALID=true

    resolve_token

    [[ "$TOKEN" = "squ_flag_token" ]]
}

@test "resolve_token: SONARQUBE_CLI_TOKEN preferred over SONAR_TOKEN" {
    TOKEN=""
    export SONARQUBE_CLI_TOKEN="squ_cli_first"
    export SONAR_TOKEN="squ_env_second"
    export MOCK_CURL_AUTH_VALID=true

    resolve_token

    [[ "$TOKEN" = "squ_cli_first" ]]
}

@test "resolve_token: falls back to CLI when no tokens and CLI has api" {
    TOKEN=""
    SONAR_CLI_HAS_API=true
    unset SONAR_TOKEN 2>/dev/null || true
    unset SONARQUBE_CLI_TOKEN 2>/dev/null || true

    run resolve_token

    assert_success
}

@test "resolve_token: fails when no tokens and no CLI api" {
    TOKEN=""
    SONAR_CLI_HAS_API=false
    unset SONAR_TOKEN 2>/dev/null || true
    unset SONARQUBE_CLI_TOKEN 2>/dev/null || true

    run resolve_token

    assert_failure
}

@test "resolve_token: skips validation in dry-run, uses first available" {
    TOKEN="squ_dryrun_token"
    DRY_RUN=true

    run resolve_token

    assert_success
}

@test "resolve_token: invalid token falls through to CLI if available" {
    TOKEN="squ_invalid"
    export MOCK_CURL_AUTH_VALID=false
    SONAR_CLI_HAS_API=true

    # Should succeed (fall through to CLI) rather than error out
    run resolve_token

    assert_success
}

@test "resolve_token: invalid token with no CLI fails" {
    TOKEN="squ_invalid"
    export MOCK_CURL_AUTH_VALID=false
    SONAR_CLI_HAS_API=false

    run resolve_token

    assert_failure
}

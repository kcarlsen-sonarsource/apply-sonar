#!/usr/bin/env bats
# Tests for ensure_auth function

load helpers/test_helper
load helpers/mock_config

@test "ensure_auth: shortcut when both TOKEN and ORG_KEY are set" {
    TOKEN="squ_valid_token"
    ORG_KEY="my-org"
    SONAR_CLI="sonar"
    export MOCK_CURL_AUTH_VALID=true

    run ensure_auth

    assert_success
}

@test "ensure_auth: authenticated CLI sets ORG_KEY from status output" {
    mock_sonar_cli_with_api
    mock_auth_status_ok "detected-org"

    ensure_auth

    [[ "$ORG_KEY" = "detected-org" ]]
}

@test "ensure_auth: authenticated CLI sets SERVER_URL from status output" {
    mock_sonar_cli_with_api
    export MOCK_SONAR_AUTH_STATUS_OUT="Authenticated.
Server https://custom.sonarcloud.io
Org    my-org"

    ensure_auth

    [[ "$SERVER_URL" = "https://custom.sonarcloud.io" ]]
}

@test "ensure_auth: not authenticated + no token + no org fails with login required" {
    SONAR_CLI="sonar"
    mock_auth_status_fail
    # Simulate login also failing
    export MOCK_SONAR_AUTH_LOGIN_EXIT=1

    run ensure_auth

    assert_failure
}

@test "ensure_auth: token without org fails with org required message" {
    SONAR_CLI="sonar"
    TOKEN="squ_valid_token"
    ORG_KEY=""
    mock_auth_status_fail

    run ensure_auth

    assert_failure
    assert_output --partial "--org is required"
}

@test "ensure_auth: dry-run with authenticated CLI" {
    mock_sonar_cli_with_api
    mock_auth_status_ok "my-org"
    DRY_RUN=true

    run ensure_auth

    assert_success
}

@test "ensure_auth: successful login but recheck fails" {
    SONAR_CLI="sonar"
    # First status fails, login succeeds, but recheck still fails (mock can't change mid-run)
    mock_auth_status_fail
    export MOCK_SONAR_AUTH_LOGIN_EXIT=0

    run ensure_auth

    # It will fail on recheck since mock state doesn't change
    assert_failure
}

@test "ensure_auth: fails when org cannot be determined" {
    mock_sonar_cli_with_api
    export MOCK_SONAR_AUTH_STATUS_EXIT=0
    export MOCK_SONAR_AUTH_STATUS_OUT="Authenticated.
Server https://sonarcloud.io"
    # No Org line in output

    run ensure_auth

    assert_failure
    assert_output --partial "Could not determine organization"
}

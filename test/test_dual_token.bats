#!/usr/bin/env bats
# Dual-token regression tests — the highest priority tests.
# These validate that when the sonar CLI has the api subcommand,
# API calls go through `sonar api` (keychain token) and NOT `curl`
# (SONAR_TOKEN env var), even when both are available.

load helpers/test_helper
load helpers/mock_config

# --------------------------------------------------------------------------
# Core regression: CLI api path is preferred over curl when both exist
# --------------------------------------------------------------------------

@test "dual-token: CLI with api + SONAR_TOKEN set — ensure_project uses sonar api, not curl" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"

    # Set SONAR_TOKEN to a DIFFERENT (wrong) token
    export SONAR_TOKEN="squ_wrong_token_for_other_org"

    # Project doesn't exist yet, create succeeds
    mock_project_not_exists
    mock_project_create_success

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success

    # The critical assertion: sonar api calls should exist
    assert log_contains "$TEST_TMPDIR/sonar_calls" "api"

    # curl should NOT have been used for API calls (it might exist for other reasons but not components/projects)
    if [[ -f "$TEST_TMPDIR/curl_calls" ]]; then
        run grep "api/components\|api/projects" "$TEST_TMPDIR/curl_calls"
        assert_failure
    fi
}

@test "dual-token: CLI with api + no SONAR_TOKEN — resolve_token succeeds with CLI fallback" {
    mock_sonar_cli_with_api
    unset SONAR_TOKEN 2>/dev/null || true
    TOKEN=""

    run resolve_token

    assert_success
    # Token should remain empty — CLI path doesn't need it
    [[ -z "$TOKEN" ]]
}

@test "dual-token: CLI with api + invalid SONAR_TOKEN — project creation uses CLI, succeeds" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"

    # Invalid SONAR_TOKEN in environment
    export SONAR_TOKEN="squ_invalid_garbage"
    export MOCK_CURL_AUTH_VALID=false

    mock_project_not_exists
    mock_project_create_success

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success

    # Verify CLI path was used
    assert log_contains "$TEST_TMPDIR/sonar_calls" "api"
}

@test "dual-token: no CLI + valid SONAR_TOKEN — falls back to curl correctly" {
    mock_no_sonar_cli
    TOKEN="squ_valid_token_12345"
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"

    mock_project_not_exists
    mock_project_create_success

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success

    # curl should have been used
    assert log_contains "$TEST_TMPDIR/curl_calls" "api/components"

    # sonar api should NOT have been called
    if [[ -f "$TEST_TMPDIR/sonar_calls" ]]; then
        run grep "api" "$TEST_TMPDIR/sonar_calls"
        assert_failure
    fi
}

@test "dual-token: CLI with api + SONAR_TOKEN — validate_org uses sonar api, not curl" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    mock_org_member

    # Set a SONAR_TOKEN that would fail if used with curl
    export SONAR_TOKEN="squ_wrong_token"

    cd "$FAKE_REPO"
    run validate_org_access

    assert_success

    # sonar api should have been used for org validation
    assert log_contains "$TEST_TMPDIR/sonar_calls" "api"
}

@test "dual-token: CLI with api + mismatched SONAR_TOKEN — configure_settings uses CLI" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"

    export SONAR_TOKEN="squ_wrong_token"

    cd "$FAKE_REPO"
    run configure_project_settings

    assert_success

    # sonar api should have been used
    assert log_contains "$TEST_TMPDIR/sonar_calls" "api"
}

#!/usr/bin/env bats
# Tests for configure_project_settings function

load helpers/test_helper
load helpers/mock_config

@test "configure_settings: dry-run skips API calls" {
    DRY_RUN=true
    PROJECT_KEY="my-org_my-project"

    run configure_project_settings

    assert_success
}

@test "configure_settings: CLI path succeeds" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"

    cd "$FAKE_REPO"
    run configure_project_settings

    assert_success
    assert_output --partial "New code definition set"
}

@test "configure_settings: curl path succeeds (204)" {
    mock_no_sonar_cli
    PROJECT_KEY="my-org_my-project"
    TOKEN="squ_valid_token"
    export MOCK_CURL_SETTINGS_HTTP=204

    cd "$FAKE_REPO"
    run configure_project_settings

    assert_success
    assert_output --partial "New code definition set"
}

@test "configure_settings: curl path handles 403 gracefully" {
    mock_no_sonar_cli
    PROJECT_KEY="my-org_my-project"
    TOKEN="squ_valid_token"
    export MOCK_CURL_SETTINGS_HTTP=403

    cd "$FAKE_REPO"
    run configure_project_settings

    # Should not fail — settings are non-critical
    assert_success
}

@test "configure_settings: CLI path failure is non-critical" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"
    export MOCK_SONAR_API_SETTINGS_EXIT=1

    cd "$FAKE_REPO"
    run configure_project_settings

    # Non-critical failure should not crash the script
    assert_success
}

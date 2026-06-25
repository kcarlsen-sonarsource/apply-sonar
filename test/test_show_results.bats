#!/usr/bin/env bats
# Tests for show_results function

load helpers/test_helper
load helpers/mock_config

@test "show_results: dry-run skips API calls" {
    DRY_RUN=true
    PROJECT_KEY="my-org_my-project"

    run show_results

    assert_success
}

@test "show_results: displays Passed for OK gate (CLI path)" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_quality_gate_ok

    cd "$FAKE_REPO"
    run show_results

    assert_success
    assert_output --partial "Passed"
}

@test "show_results: displays Failed for ERROR gate (CLI path)" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_quality_gate_error

    cd "$FAKE_REPO"
    run show_results

    assert_success
    assert_output --partial "Failed"
}

@test "show_results: displays Not Computed for NONE gate" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_quality_gate_none

    cd "$FAKE_REPO"
    run show_results

    assert_success
    assert_output --partial "Not Computed"
}

@test "show_results: curl path displays results" {
    mock_no_sonar_cli
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_quality_gate_ok

    cd "$FAKE_REPO"
    run show_results

    assert_success
    assert_output --partial "Passed"
}

@test "show_results: shows dashboard URL" {
    mock_sonar_cli_with_api
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"

    cd "$FAKE_REPO"
    run show_results

    assert_success
    assert_output --partial "sonarcloud.io/project/overview?id=my-org_my-project"
}

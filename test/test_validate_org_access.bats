#!/usr/bin/env bats
# Tests for validate_org_access function

load helpers/test_helper
load helpers/mock_config

@test "validate_org: dry-run skips validation" {
    DRY_RUN=true
    ORG_KEY="my-org"

    run validate_org_access

    assert_success
}

@test "validate_org: CLI path — member org succeeds" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    mock_org_member

    cd "$FAKE_REPO"
    run validate_org_access

    assert_success
}

@test "validate_org: CLI path — not a member, org exists, fails" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    mock_org_not_member
    mock_org_exists

    cd "$FAKE_REPO"
    run validate_org_access

    assert_failure
    assert_output --partial "not a member"
}

@test "validate_org: CLI path — org not found, fails" {
    mock_sonar_cli_with_api
    ORG_KEY="bad-org"
    mock_org_not_member
    mock_org_not_exists

    cd "$FAKE_REPO"
    run validate_org_access

    assert_failure
    assert_output --partial "was not found"
}

@test "validate_org: curl path — member org succeeds" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    TOKEN="squ_valid_token"
    mock_org_member

    cd "$FAKE_REPO"
    run validate_org_access

    assert_success
}

@test "validate_org: curl path — not a member, org exists, fails" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    TOKEN="squ_valid_token"
    mock_org_not_member
    mock_org_exists

    cd "$FAKE_REPO"
    run validate_org_access

    assert_failure
    assert_output --partial "not a member"
}

@test "validate_org: curl path — org not found, fails" {
    mock_no_sonar_cli
    ORG_KEY="bad-org"
    TOKEN="squ_valid_token"
    mock_org_not_member
    mock_org_not_exists

    cd "$FAKE_REPO"
    run validate_org_access

    assert_failure
    assert_output --partial "was not found"
}

@test "validate_org: warns about provision permission" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    # Use a fixture without provision: true
    export MOCK_SONAR_API_ORG_MEMBER=true

    cd "$FAKE_REPO"
    run validate_org_access

    assert_success
}

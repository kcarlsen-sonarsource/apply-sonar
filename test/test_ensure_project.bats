#!/usr/bin/env bats
# Tests for ensure_project_exists function (both CLI and curl paths)

load helpers/test_helper
load helpers/mock_config

# --------------------------------------------------------------------------
# Dry-run
# --------------------------------------------------------------------------

@test "ensure_project: dry-run skips everything" {
    DRY_RUN=true
    PROJECT_KEY="my-org_my-project"

    run ensure_project_exists

    assert_success
}

# --------------------------------------------------------------------------
# CLI path (ensure_project_exists_via_cli)
# --------------------------------------------------------------------------

@test "ensure_project: CLI path — project already exists" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_project_exists

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success
    assert_output --partial "already exists"
}

@test "ensure_project: CLI path — project created successfully" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_project_not_exists
    mock_project_create_success

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success
    assert_output --partial "Project created"
}

@test "ensure_project: CLI path — no org error" {
    mock_sonar_cli_with_api
    ORG_KEY="bad-org"
    PROJECT_KEY="bad-org_my-project"
    PROJECT_NAME="my-project"
    mock_project_not_exists
    mock_project_create_no_org

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "was not found"
}

@test "ensure_project: CLI path — key already exists error" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_project_not_exists
    mock_project_create_key_exists

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "already exists"
}

@test "ensure_project: CLI path — permission denied error" {
    mock_sonar_cli_with_api
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    mock_project_not_exists
    mock_project_create_permission_denied

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "Permission denied"
}

# --------------------------------------------------------------------------
# curl path (ensure_project_exists_via_curl)
# --------------------------------------------------------------------------

@test "ensure_project: curl path — project already exists (HTTP 200)" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_project_exists

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success
    assert_output --partial "already exists"
}

@test "ensure_project: curl path — project created successfully" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_project_not_exists
    mock_project_create_success

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_success
    assert_output --partial "Project created"
}

@test "ensure_project: curl path — no org error (HTTP 404)" {
    mock_no_sonar_cli
    ORG_KEY="bad-org"
    PROJECT_KEY="bad-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_project_not_exists
    mock_project_create_no_org

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "was not found"
}

@test "ensure_project: curl path — permission denied (HTTP 403)" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_project_not_exists
    mock_project_create_permission_denied

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "Authentication/authorization error"
}

@test "ensure_project: curl path — key exists in 2xx response body" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_valid_token"
    mock_project_not_exists
    mock_project_create_key_exists

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "already exists"
}

@test "ensure_project: curl path — auth error checking project (HTTP 401)" {
    mock_no_sonar_cli
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    PROJECT_NAME="my-project"
    TOKEN="squ_bad_token"
    export MOCK_CURL_COMPONENT_HTTP=401

    cd "$FAKE_REPO"
    run ensure_project_exists

    assert_failure
    assert_output --partial "Authentication/authorization error"
}

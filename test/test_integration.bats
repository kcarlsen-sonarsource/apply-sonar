#!/usr/bin/env bats
# Integration tests — run apply-sonar.sh as a subprocess

load helpers/test_helper
load helpers/mock_config

# Integration tests need to unset APPLY_SONAR_SOURCED so the script runs main()
# The test_helper sets it for unit tests (sourcing), but integration tests
# invoke the script as a subprocess.

@test "integration: dry-run happy path with CLI" {
    export MOCK_SONAR_AUTH_STATUS_EXIT=0
    export MOCK_SONAR_AUTH_STATUS_OUT="Authenticated.
Server https://sonarcloud.io
Org    my-org"
    export MOCK_SONAR_API_SUPPORTED=true
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"
    export MOCK_CURL_AUTH_VALID=true
    unset APPLY_SONAR_SOURCED

    cd "$FAKE_REPO"

    run "$PROJECT_ROOT/apply-sonar.sh" --dry-run

    assert_success
}

@test "integration: dry-run with --token and --org" {
    export MOCK_SONAR_API_SUPPORTED=true
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"
    unset APPLY_SONAR_SOURCED

    cd "$FAKE_REPO"

    run "$PROJECT_ROOT/apply-sonar.sh" --token "squ_test_token" --org "my-org" --dry-run

    assert_success
}

@test "integration: dry-run with all explicit flags" {
    export MOCK_SONAR_API_SUPPORTED=true
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"
    unset APPLY_SONAR_SOURCED

    cd "$FAKE_REPO"

    run "$PROJECT_ROOT/apply-sonar.sh" \
        --token "squ_test_token" \
        --org "my-org" \
        --key "custom-key" \
        --name "Custom Name" \
        --dry-run --verbose

    assert_success
}

@test "integration: --help exits successfully" {
    unset APPLY_SONAR_SOURCED

    cd "$FAKE_REPO"

    run "$PROJECT_ROOT/apply-sonar.sh" --help

    assert_success
    assert_output --partial "Usage:"
}

@test "integration: unknown flag fails" {
    unset APPLY_SONAR_SOURCED

    cd "$FAKE_REPO"

    run "$PROJECT_ROOT/apply-sonar.sh" --bad-flag

    assert_failure
}

#!/usr/bin/env bats
# Tests for parse_args function

load helpers/test_helper
load helpers/mock_config

@test "parse_args: --org sets ORG_KEY" {
    parse_args --org "test-org"
    [[ "$ORG_KEY" = "test-org" ]]
}

@test "parse_args: --key sets PROJECT_KEY" {
    parse_args --key "test-key"
    [[ "$PROJECT_KEY" = "test-key" ]]
}

@test "parse_args: --name sets PROJECT_NAME" {
    parse_args --name "Test Project"
    [[ "$PROJECT_NAME" = "Test Project" ]]
}

@test "parse_args: --token sets TOKEN" {
    parse_args --token "squ_abc123"
    [[ "$TOKEN" = "squ_abc123" ]]
}

@test "parse_args: --dry-run sets DRY_RUN" {
    parse_args --dry-run
    [[ "$DRY_RUN" = "true" ]]
}

@test "parse_args: --verbose sets VERBOSE" {
    parse_args --verbose
    [[ "$VERBOSE" = "true" ]]
}

@test "parse_args: --force sets FORCE" {
    parse_args --force
    [[ "$FORCE" = "true" ]]
}

@test "parse_args: --integrate-claude sets INTEGRATE_CLAUDE" {
    parse_args --integrate-claude
    [[ "$INTEGRATE_CLAUDE" = "true" ]]
}

@test "parse_args: multiple flags work together" {
    parse_args --org "my-org" --key "my-key" --dry-run --verbose
    [[ "$ORG_KEY" = "my-org" ]]
    [[ "$PROJECT_KEY" = "my-key" ]]
    [[ "$DRY_RUN" = "true" ]]
    [[ "$VERBOSE" = "true" ]]
}

@test "parse_args: missing value for --org fails" {
    run parse_args --org
    assert_failure
}

@test "parse_args: missing value for --token fails" {
    run parse_args --token
    assert_failure
}

@test "parse_args: unknown flag fails" {
    run parse_args --unknown-flag
    assert_failure
}

@test "parse_args: --help exits 0" {
    run parse_args --help
    assert_success
}

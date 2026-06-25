#!/usr/bin/env bats
# Tests for write_config_files function

load helpers/test_helper
load helpers/mock_config

@test "write_config: creates sonar-project.properties" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"

    cd "$FAKE_REPO"
    run write_config_files

    assert_success
    [[ -f "$FAKE_REPO/sonar-project.properties" ]]
    grep -q "sonar.organization=my-org" "$FAKE_REPO/sonar-project.properties"
    grep -q "sonar.projectKey=my-org_my-project" "$FAKE_REPO/sonar-project.properties"
}

@test "write_config: creates .sonarlint/connectedMode.json" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"

    cd "$FAKE_REPO"
    run write_config_files

    assert_success
    [[ -f "$FAKE_REPO/.sonarlint/connectedMode.json" ]]
    jq -e '.sonarCloudOrganization == "my-org"' "$FAKE_REPO/.sonarlint/connectedMode.json"
    jq -e '.projectKey == "my-org_my-project"' "$FAKE_REPO/.sonarlint/connectedMode.json"
}

@test "write_config: does not overwrite existing files without --force" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"

    cd "$FAKE_REPO"
    echo "existing" > "$FAKE_REPO/sonar-project.properties"

    run write_config_files

    assert_success
    # File should still have original content
    grep -q "existing" "$FAKE_REPO/sonar-project.properties"
}

@test "write_config: --force overwrites existing files" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    FORCE=true

    cd "$FAKE_REPO"
    echo "existing" > "$FAKE_REPO/sonar-project.properties"

    run write_config_files

    assert_success
    assert_output --partial "Overwritten"
    grep -q "sonar.organization=my-org" "$FAKE_REPO/sonar-project.properties"
}

@test "write_config: dry-run does not create files" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"
    DRY_RUN=true

    cd "$FAKE_REPO"
    run write_config_files

    assert_success
    [[ ! -f "$FAKE_REPO/sonar-project.properties" ]]
}

@test "write_config: creates .sonarlint directory if missing" {
    ORG_KEY="my-org"
    PROJECT_KEY="my-org_my-project"

    cd "$FAKE_REPO"
    [[ ! -d "$FAKE_REPO/.sonarlint" ]]

    run write_config_files

    assert_success
    [[ -d "$FAKE_REPO/.sonarlint" ]]
}

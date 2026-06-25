#!/usr/bin/env bats
# Tests for detect_project_info function

load helpers/test_helper
load helpers/mock_config

@test "detect_project_info: derives PROJECT_KEY from org + repo name" {
    ORG_KEY="my-org"
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"

    cd "$FAKE_REPO"
    detect_project_info

    [[ "$PROJECT_KEY" = "my-org_my-project" ]]
}

@test "detect_project_info: derives PROJECT_NAME from repo name" {
    ORG_KEY="my-org"
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/cool-app.git"

    cd "$FAKE_REPO"
    detect_project_info

    [[ "$PROJECT_NAME" = "cool-app" ]]
}

@test "detect_project_info: does not override explicit PROJECT_KEY" {
    ORG_KEY="my-org"
    PROJECT_KEY="custom-key"
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"

    cd "$FAKE_REPO"
    detect_project_info

    [[ "$PROJECT_KEY" = "custom-key" ]]
}

@test "detect_project_info: does not override explicit PROJECT_NAME" {
    ORG_KEY="my-org"
    PROJECT_NAME="Custom Name"
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"

    cd "$FAKE_REPO"
    detect_project_info

    [[ "$PROJECT_NAME" = "Custom Name" ]]
}

@test "detect_project_info: handles SSH remote URL" {
    ORG_KEY="my-org"
    export MOCK_GIT_REMOTE_URL="git@github.com:my-org/ssh-project.git"

    cd "$FAKE_REPO"
    detect_project_info

    [[ "$PROJECT_KEY" = "my-org_ssh-project" ]]
    [[ "$PROJECT_NAME" = "ssh-project" ]]
}

@test "detect_project_info: sanitizes invalid characters in project key" {
    ORG_KEY="my-org"
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my project (v2).git"

    cd "$FAKE_REPO"
    detect_project_info

    # Spaces and parens should be replaced with hyphens
    [[ "$PROJECT_KEY" =~ ^[a-zA-Z0-9_.:/-]+$ ]] || [[ "$PROJECT_KEY" =~ ^[a-zA-Z0-9_.:-]+$ ]]
}

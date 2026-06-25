# mock_config.bash — convenience functions for configuring mock behavior

# --- sonar CLI configuration ---

mock_sonar_cli_with_api() {
    SONAR_CLI="sonar"
    SONAR_CLI_HAS_API=true
}

mock_sonar_cli_without_api() {
    SONAR_CLI="sonar"
    SONAR_CLI_HAS_API=false
    export MOCK_SONAR_API_SUPPORTED=false
}

mock_no_sonar_cli() {
    SONAR_CLI=""
    SONAR_CLI_HAS_API=false
}

# --- Token configuration ---

mock_valid_token() {
    TOKEN="${1:-squ_valid_token_12345}"
    export MOCK_CURL_AUTH_VALID=true
}

mock_invalid_token() {
    TOKEN="${1:-squ_invalid_token_99999}"
    export MOCK_CURL_AUTH_VALID=false
}

mock_sonar_token_env() {
    export SONAR_TOKEN="${1:-squ_env_token_67890}"
}

mock_sonarqube_cli_token_env() {
    export SONARQUBE_CLI_TOKEN="${1:-squ_cli_token_11111}"
}

# --- Auth status ---

mock_auth_status_ok() {
    export MOCK_SONAR_AUTH_STATUS_EXIT=0
    export MOCK_SONAR_AUTH_STATUS_OUT="Authenticated.
Server https://sonarcloud.io
Org    ${1:-my-org}"
}

mock_auth_status_fail() {
    export MOCK_SONAR_AUTH_STATUS_EXIT=1
    export MOCK_SONAR_AUTH_STATUS_OUT="Not authenticated."
}

# --- Organization ---

mock_org_member() {
    export MOCK_SONAR_API_ORG_MEMBER=true
    export MOCK_CURL_ORG_MEMBER=true
}

mock_org_not_member() {
    export MOCK_SONAR_API_ORG_MEMBER=false
    export MOCK_CURL_ORG_MEMBER=false
}

mock_org_exists() {
    export MOCK_SONAR_API_ORG_EXISTS=true
    export MOCK_CURL_ORG_EXISTS=true
}

mock_org_not_exists() {
    export MOCK_SONAR_API_ORG_EXISTS=false
    export MOCK_CURL_ORG_EXISTS=false
}

# --- Project ---

mock_project_exists() {
    export MOCK_SONAR_API_PROJECT_EXISTS=true
    export MOCK_CURL_PROJECT_EXISTS=true
}

mock_project_not_exists() {
    export MOCK_SONAR_API_PROJECT_EXISTS=false
    export MOCK_CURL_PROJECT_EXISTS=false
}

mock_project_create_success() {
    export MOCK_SONAR_API_PROJECT_CREATE=success
    export MOCK_CURL_PROJECT_CREATE=success
}

mock_project_create_no_org() {
    export MOCK_SONAR_API_PROJECT_CREATE=no_org
    export MOCK_CURL_PROJECT_CREATE=no_org
}

mock_project_create_key_exists() {
    export MOCK_SONAR_API_PROJECT_CREATE=key_exists
    export MOCK_CURL_PROJECT_CREATE=key_exists
}

mock_project_create_permission_denied() {
    export MOCK_SONAR_API_PROJECT_CREATE=permission_denied
    export MOCK_CURL_PROJECT_CREATE=permission_denied
}

# --- Quality gate ---

mock_quality_gate_ok() {
    export MOCK_SONAR_API_QUALITY_GATE=ok
    export MOCK_CURL_QUALITY_GATE=ok
}

mock_quality_gate_error() {
    export MOCK_SONAR_API_QUALITY_GATE=error
    export MOCK_CURL_QUALITY_GATE=error
}

mock_quality_gate_none() {
    export MOCK_SONAR_API_QUALITY_GATE=none
    export MOCK_CURL_QUALITY_GATE=none
}

# --- Standard test scenarios ---

# Happy path: CLI with api, authenticated, org member, project doesn't exist yet
mock_happy_path_cli() {
    mock_sonar_cli_with_api
    mock_auth_status_ok
    mock_org_member
    mock_project_not_exists
    mock_project_create_success
    ORG_KEY="my-org"
}

# Happy path: curl fallback with valid token
mock_happy_path_curl() {
    mock_no_sonar_cli
    mock_valid_token
    mock_org_member
    mock_project_not_exists
    mock_project_create_success
    ORG_KEY="my-org"
    TOKEN="squ_valid_token_12345"
}

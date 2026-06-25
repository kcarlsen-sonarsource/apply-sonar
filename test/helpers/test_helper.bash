# test_helper.bash — BATS test helper for apply-sonar.sh
# Loaded by every .bats file. Sets up temp dirs, PATH, and sources the script.

# Locate the project root (two levels up from this helper)
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Load BATS libraries
load "${TEST_DIR}/bats/bats-support/load"
load "${TEST_DIR}/bats/bats-assert/load"

# Export fixture dir for mock shims
export FIXTURE_DIR="${TEST_DIR}/fixtures"

setup() {
    # Create a temp directory for this test
    TEST_TMPDIR="$(mktemp -d)"
    export TEST_TMPDIR

    # Create a fake HOME so we don't pollute real home
    export HOME="$TEST_TMPDIR/home"
    mkdir -p "$HOME"

    # Create a fake git repo in the temp dir
    export FAKE_REPO="$TEST_TMPDIR/repo"
    mkdir -p "$FAKE_REPO"
    (
        cd "$FAKE_REPO"
        git init -q
        git config user.email "test@test.com"
        git config user.name "Test"
        echo "test" > README.md
        git add README.md
        git commit -q -m "init"
    )

    # Prepend test/bin to PATH so mock shims are found first
    export PATH="${TEST_DIR}/bin:$PATH"

    # Set mock git remote
    export MOCK_GIT_REMOTE_URL="https://github.com/my-org/my-project.git"

    # Source the script in library mode
    export APPLY_SONAR_SOURCED=1
    # shellcheck source=../../apply-sonar.sh
    source "${PROJECT_ROOT}/apply-sonar.sh"

    # Reset all global variables to defaults
    ORG_KEY=""
    PROJECT_KEY=""
    PROJECT_NAME=""
    TOKEN=""
    SERVER_URL="https://sonarcloud.io"
    DRY_RUN=false
    VERBOSE=false
    FORCE=false
    INTEGRATE_CLAUDE=false
    SONAR_CLI=""
    SONAR_CLI_HAS_API=false
    SCANNER_CMD=""
    USE_DOCKER=false
    TMPFILES=()

    # Reset mock env vars to safe defaults
    export MOCK_SONAR_AUTH_STATUS_EXIT=0
    export MOCK_SONAR_AUTH_STATUS_OUT="Authenticated.
Server https://sonarcloud.io
Org    my-org"
    export MOCK_SONAR_AUTH_LOGIN_EXIT=0
    export MOCK_SONAR_API_SUPPORTED=true
    export MOCK_SONAR_API_AUTH_VALID=true
    export MOCK_SONAR_API_ORG_MEMBER=true
    export MOCK_SONAR_API_ORG_EXISTS=true
    export MOCK_SONAR_API_PROJECT_EXISTS=false
    export MOCK_SONAR_API_COMPONENT_EXIT=1
    export MOCK_SONAR_API_PROJECT_CREATE=success
    export MOCK_SONAR_API_SETTINGS_EXIT=0
    export MOCK_SONAR_API_QUALITY_GATE=ok
    export MOCK_SONAR_INTEGRATE_SUPPORTED=true
    export MOCK_SONAR_INTEGRATE_EXIT=0

    export MOCK_CURL_AUTH_VALID=true
    export MOCK_CURL_ORG_MEMBER=true
    export MOCK_CURL_ORG_EXISTS=true
    export MOCK_CURL_PROJECT_EXISTS=false
    export MOCK_CURL_COMPONENT_HTTP=404
    export MOCK_CURL_PROJECT_CREATE=success
    export MOCK_CURL_SETTINGS_HTTP=204
    export MOCK_CURL_QUALITY_GATE=ok
    export MOCK_CURL_EXIT=0

    export MOCK_DOCKER_AVAILABLE=false
    export MOCK_SCANNER_EXIT=0

    # Clear any SONAR_TOKEN from the environment
    unset SONAR_TOKEN 2>/dev/null || true
    unset SONARQUBE_CLI_TOKEN 2>/dev/null || true
}

teardown() {
    # Clean up temp directory
    if [[ -n "${TEST_TMPDIR:-}" ]] && [[ -d "$TEST_TMPDIR" ]]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# Utility: count lines in a log file
count_calls() {
    local logfile="$1"
    if [[ -f "$logfile" ]]; then
        wc -l < "$logfile" | tr -d ' '
    else
        echo "0"
    fi
}

# Utility: check if a log file contains a pattern
log_contains() {
    local logfile="$1"
    local pattern="$2"
    [[ -f "$logfile" ]] && grep -q "$pattern" "$logfile"
}

# Utility: assert no calls were logged to a file
assert_no_calls() {
    local logfile="$1"
    if [[ -f "$logfile" ]]; then
        local count
        count="$(wc -l < "$logfile" | tr -d ' ')"
        if [[ "$count" -ne 0 ]]; then
            echo "Expected no calls in $logfile but found $count:" >&2
            cat "$logfile" >&2
            return 1
        fi
    fi
}

#!/usr/bin/env bats
# Tests for ensure_scanner function

load helpers/test_helper
load helpers/mock_config

# Helper to set up PATH without sonar-scanner but with other shims.
# We must also hide any real sonar-scanner on the system.
_setup_path_without_scanner() {
    mkdir -p "$TEST_TMPDIR/partial_bin"
    for shim in sonar curl docker git; do
        cp "${TEST_DIR}/bin/$shim" "$TEST_TMPDIR/partial_bin/$shim"
        chmod +x "$TEST_TMPDIR/partial_bin/$shim"
    done
    # Also add a fake sonar-scanner that "doesn't exist" (command -v won't find it
    # if we just don't put it in PATH). But we need real binaries like jq, unzip, etc.
    # So build a clean PATH with only essentials + our partial_bin.
    local new_path="$TEST_TMPDIR/partial_bin"
    # Add common system paths (but create a sonar-scanner blocker in partial_bin)
    # Actually the cleanest approach: create a sonar-scanner in partial_bin that
    # makes command -v succeed but we override the function to skip it.
    # Simplest: just rename the function test differently.

    # Build PATH from scratch with only system dirs, skipping any dir containing sonar-scanner
    local IFS=':'
    for p in $PATH; do
        case "$p" in
            "${TEST_DIR}/bin") continue ;;
        esac
        if [[ -x "$p/sonar-scanner" ]]; then
            # This dir has sonar-scanner — add all its other binaries via symlinks
            # but skip sonar-scanner itself
            continue
        fi
        new_path="$new_path:$p"
    done
    PATH="$new_path"
    export PATH

    # Verify sonar-scanner is truly not findable
    if command -v sonar-scanner > /dev/null 2>&1; then
        # If it's still found (e.g. via hash), add essential system tools manually
        # and strip all existing paths
        local essential_path="$TEST_TMPDIR/partial_bin"
        for dir in /usr/bin /bin /usr/sbin /sbin; do
            [[ -d "$dir" ]] && essential_path="$essential_path:$dir"
        done
        PATH="$essential_path"
        export PATH
    fi
}

@test "ensure_scanner: finds sonar-scanner on PATH" {
    cd "$FAKE_REPO"
    run ensure_scanner

    assert_success
    assert_output --partial "sonar-scanner ready"
}

@test "ensure_scanner: falls back to Docker when sonar-scanner not found" {
    _setup_path_without_scanner
    export MOCK_DOCKER_AVAILABLE=true

    cd "$FAKE_REPO"
    run ensure_scanner

    assert_success
    assert_output --partial "Docker"
}

@test "ensure_scanner: dry-run when nothing available" {
    _setup_path_without_scanner
    export MOCK_DOCKER_AVAILABLE=false
    DRY_RUN=true

    cd "$FAKE_REPO"
    run ensure_scanner

    assert_success
}

@test "ensure_scanner: finds local scanner at HOME path" {
    _setup_path_without_scanner

    # Create a mock scanner at the expected local path
    mkdir -p "$HOME/.sonar/sonar-scanner/bin"
    cat > "$HOME/.sonar/sonar-scanner/bin/sonar-scanner" << 'SCANNER'
#!/usr/bin/env bash
echo "SonarScanner CLI 8.0.1.6346"
SCANNER
    chmod +x "$HOME/.sonar/sonar-scanner/bin/sonar-scanner"

    cd "$FAKE_REPO"
    run ensure_scanner

    assert_success
    assert_output --partial "sonar-scanner ready"
}

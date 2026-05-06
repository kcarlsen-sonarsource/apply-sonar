# apply-sonar

One-command SonarQube Cloud setup for local projects.

## Prerequisites

- git, curl, jq, unzip
- A [SonarQube Cloud](https://sonarcloud.io) account and organization (create one at [sonarcloud.io](https://sonarcloud.io) if you don't have one)
- The [sonar CLI](https://github.com/SonarSource/sonarqube-cli) is installed automatically when needed for interactive auth. Not required when using `--token` and `--org`.

## Install

```bash
git clone https://github.com/kcarlsen-sonarsource/apply-sonar.git
chmod +x apply-sonar/apply-sonar.sh
```

## Usage

```
Usage: apply-sonar [OPTIONS]

Sets up a SonarQube Cloud project from a local git repository.
Handles auth, project creation, config generation, and first scan.

Options:
  --org <key>            Organization key (auto-detected from auth)
  --key <key>            Project key (auto-generated from org + repo name)
  --name <name>          Project display name (defaults to repo name)
  --token <token>        Auth token (skips browser login)
  --integrate-claude     Also run 'sonar integrate claude' after setup
  --force                Overwrite existing config files
  --dry-run              Show what would happen without making changes
  --verbose              Show detailed output
  --help                 Show this help message
```

> **`--integrate-claude`**: Configures the SonarQube MCP server and secrets scanning hooks for Claude Code sessions.

## What it does

1. **Auth** — authenticates with SonarQube Cloud (browser login or token)
2. **Detect** — infers org, project key, and name from git
3. **Create** — creates the project in SonarQube Cloud if it doesn't exist
4. **Settings** — sets new code definition to "previous version"
5. **Config** — writes `sonar-project.properties` and `.sonarlint/connectedMode.json`
6. **Scanner** — checks for sonar-scanner on PATH or in `~/.sonar`, tries Docker (`sonarsource/sonar-scanner-cli`) if available, or offers to download
7. **Scan** — runs the first analysis with friendly error handling
8. **Results** — displays quality gate status and a dashboard link

## Examples

```bash
# Basic — interactive auth, auto-detect everything
./apply-sonar.sh

# CI — pass token and org directly
./apply-sonar.sh --token "$SONAR_TOKEN" --org my-org

# Custom project display name
./apply-sonar.sh --token "$SONAR_TOKEN" --org my-org --name "My Cool Project"

# Preview without making changes
./apply-sonar.sh --dry-run

# Also configure Claude Code integration
./apply-sonar.sh --integrate-claude
```

## Limitations

- SonarQube Cloud only (not self-hosted SonarQube Server)
- Defaults to sonarcloud.io (no --server flag; server URL is inferred from CLI auth state)
- No coverage setup (requires build-tool-specific config)
- No CI pipeline generation
- No Enterprise or SSO authentication
- No monorepo support (single project per run)

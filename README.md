# Grafantastic

PR-scoped observability signal extractor and Grafana dashboard generator.

## Overview

Grafantastic statically analyzes Ruby source code changed in a Pull Request and generates a Grafana dashboard JSON containing panels relevant to the observability signals found in that code.

## Installation

```bash
gem install grafantastic
```

Or from source:

```bash
gem build grafantastic.gemspec
gem install grafantastic-0.1.0.gem
```

## Quick Start

### 1. Configure Grafana Connection

```bash
# Set your Grafana credentials (stored in ~/.grafantastic.yml)
grafantastic config set grafana_url https://myorg.grafana.net --global
grafantastic config set grafana_token glsa_xxxxxxxxxxxx --global

# List available folders
grafantastic config folders

# Set target folder for dashboards
grafantastic config set grafana_folder_id 42
```

### 2. Generate Dashboard

```bash
# From your repo with changed files
grafantastic

# Or dry-run to see JSON without uploading
grafantastic --dry-run
```

## CLI Commands

### Main Command

```bash
grafantastic [options]
```

**Options:**
- `--dry-run` - Generate JSON only, don't upload to Grafana
- `--verbose` - Show detailed progress and dynamic metric warnings
- `--help` - Show help

### Config Command

```bash
grafantastic config <action> [options]
```

**Actions:**
- `set <key> <value>` - Set a config value
- `get <key>` - Get a config value
- `list` - Show all config values
- `delete <key>` - Delete a config value
- `folders` - List available Grafana folders

**Options:**
- `--global` - Apply to `~/.grafantastic.yml` (default: local `.grafantastic.yml`)

**Available Keys:**
- `grafana_url` - Grafana instance URL
- `grafana_token` - Grafana API token
- `grafana_folder_id` - Target folder ID for dashboards
- `grafana_folder_name` - Target folder name (for display)

### Configuration Precedence

1. Environment variables (highest priority)
2. Local `.grafantastic.yml` (in current directory)
3. Global `~/.grafantastic.yml` (lowest priority)

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GRAFANA_URL` | Grafana instance URL |
| `GRAFANA_TOKEN` | Grafana API token |
| `GRAFANA_FOLDER_ID` | Target folder ID (optional) |
| `GRAFANTASTIC_DRY_RUN` | Set to `true` to force dry-run mode |

## Output

When signals are found, you'll see:

```
[grafantastic] Found: 2 logs, 3 counters, 1 histogram
[grafantastic] Creating dashboard with 3 panels
[grafantastic] Please see: 1 dynamic metric could not be added
```

**If no signals are found, no dashboard is created.** The gem exits cleanly with a message:

```
[grafantastic] No observability signals found in changed files
[grafantastic] Dashboard not created
```

## Observability Signals

### Logs

- `logger.info`, `logger.debug`, `logger.warn`, `logger.error`, `logger.fatal`
- `Rails.logger.*`
- `@logger.*`

### Metrics

| Client | Methods |
|--------|---------|
| Prometheus | `counter`, `gauge`, `histogram`, `summary` |
| StatsD | `increment`, `decrement`, `gauge`, `timing`, `time` |
| Statsd | (same as StatsD) |
| Hesiod | `emit` |

### Dynamic Metrics Warning

Metrics with runtime-determined names cannot be added to dashboards:

```ruby
# ❌ Dynamic - cannot be analyzed statically
Prometheus.counter(entity.id).increment

# ✅ Static - will be detected and added to dashboard
Prometheus.counter(:records_processed).increment(labels: { entity_id: id })
```

When dynamic metrics are detected, you'll see a warning. Use `--verbose` for details:

```
[grafantastic] ⚠️  Dynamic metrics use runtime values and cannot be added to the dashboard:
  • app/services/processor.rb:42 - Prometheus.counter in RecordProcessor

[grafantastic] Tip: Use static metric names with labels instead:
  Prometheus.counter(:my_metric).increment(labels: { entity_id: id })
```

## Guard Rails

Hard limits prevent noisy dashboards:

| Signal Type | Max Count |
|-------------|-----------|
| Logs | 10 |
| Metrics | 10 |
| Events | 5 |
| Total Panels | 12 |

If any limit is exceeded, the gem aborts with a clear error message and exits with code 1.

## File Filtering

**Included:**
- Files ending with `.rb`
- Ruby application code

**Excluded:**
- `*_spec.rb`, `*_test.rb`
- Files in `/spec/`, `/test/`, `/config/`
- Non-Ruby files

## Inheritance

Signals are extracted from:
- The touched class/module (depth = 0)
- Its direct parent class (depth = 1)

Grandparents and deeper ancestors are not traversed.

## Dashboard Behavior

- **Deterministic UID:** Dashboard UID is derived from the branch name, ensuring the same PR always updates the same dashboard
- **Overwrite:** Re-running the gem updates the existing dashboard rather than creating duplicates
- **Template Variables:** Dashboards include `$service`, `$env`, and `$datasource` variables

## GitHub Actions Integration

Grafantastic works great as a GitHub Action that automatically creates dashboards for PRs.

### Setup

1. **Add secrets to your repository:**
   - `GRAFANA_URL` - Your Grafana instance URL
   - `GRAFANA_TOKEN` - Service Account token with Editor role
   - `GRAFANA_FOLDER_ID` (optional) - Folder ID for dashboards

2. **Create workflow file** `.github/workflows/pr-dashboard.yml`:

```yaml
name: PR Observability Dashboard

on:
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  dashboard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.x'

      - name: Install grafantastic
        run: gem install grafantastic

      - name: Generate dashboard
        env:
          GRAFANA_URL: ${{ secrets.GRAFANA_URL }}
          GRAFANA_TOKEN: ${{ secrets.GRAFANA_TOKEN }}
          GRAFANA_FOLDER_ID: ${{ secrets.GRAFANA_FOLDER_ID }}
        run: grafantastic --verbose
```

### What Developers See

When a PR is opened with Ruby file changes containing observability signals, a dashboard is created and the workflow logs show:

```
[grafantastic] Found: 2 logs, 1 counter
[grafantastic] Creating dashboard with 2 panels
Dashboard uploaded: https://myorg.grafana.net/d/feature-branch/feature-branch
```

## Architecture

```
Git context (changed files, branch name)
              ↓
     Ruby source files
              ↓
    AST analysis (parser gem)
              ↓
   Signal extraction (logs, metrics)
              ↓
    Validation (guard rails)
              ↓
   Dashboard JSON generation
              ↓
    Upload to Grafana API
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Build gem
gem build grafantastic.gemspec
```

## License

MIT

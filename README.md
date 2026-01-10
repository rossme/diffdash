# Grafanatic

PR-scoped observability signal extractor and Grafana dashboard generator.

## Overview

Grafanatic statically analyzes Ruby source code changed in a Pull Request and generates a Grafana dashboard JSON containing panels relevant to the observability signals found in that code.

## Installation

```bash
bundle install
```

Or install the gem:

```bash
gem build grafanatic.gemspec
gem install grafanatic-0.1.0.gem
```

## Usage

### Generate Dashboard (CLI)

```bash
# Generate dashboard JSON to stdout
bundle exec grafanatic

# With verbose output
bundle exec grafanatic --verbose

# Dry run (never upload)
bundle exec grafanatic --dry-run
```

### Using Make

```bash
# Generate dashboard
make dashboard

# Verbose mode
make dashboard-verbose

# Dry run
make dashboard-dry
```

### Environment Variables

Create a `.env` file:

```bash
GRAFANA_URL=https://grafana.example.com
GRAFANA_TOKEN=your-api-token
GRAFANA_FOLDER_ID=123          # Optional
GRAFANATIC_DRY_RUN=true        # Optional, forces dry-run mode
```

## Observability Signals

The gem detects:

### Logs

- `logger.info`, `logger.error`, `logger.warn`, etc.
- `Rails.logger.*`

### Metrics

- Prometheus: `Prometheus.counter`, `Prometheus.histogram`, etc.
- StatsD: `StatsD.increment`, `StatsD.timing`, etc.
- Hesiod: `Hesiod.emit`

## Guard Rails

Hard limits are enforced:

| Signal Type | Max Count |
|-------------|-----------|
| Logs        | 10        |
| Metrics     | 10        |
| Events      | 5         |
| Total Panels| 12        |

If any limit is exceeded, the gem aborts with a clear error message.

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

Grandparents and deeper are not traversed.

## Output

The gem outputs valid Grafana dashboard JSON to STDOUT. Errors and progress information go to STDERR.

If no observability signals are found, a dashboard with a single text panel is generated.

## Architecture

```
Ruby source code
       ↓
AST analysis (parser gem)
       ↓
Observability signals
       ↓
Validation (guard rails)
       ↓
Grafana dashboard JSON
```

## Development

```bash
# Install dependencies
make install

# Run linter
make lint

# Run tests
make test
```

## License

MIT

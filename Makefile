.PHONY: dashboard install lint test clean

# Generate dashboard JSON and print to stdout
dashboard:
	@bundle exec grafanatic

# Generate dashboard with verbose output
dashboard-verbose:
	@bundle exec grafanatic --verbose

# Dry run - generate JSON only, never upload
dashboard-dry:
	@bundle exec grafanatic --dry-run

# Install dependencies
install:
	@bundle install

# Run linter
lint:
	@bundle exec rubocop

# Run tests
test:
	@bundle exec rspec

# Clean generated files
clean:
	@rm -rf coverage/ tmp/ .bundle/

# Build the gem
build:
	@gem build grafanatic.gemspec

# Install the gem locally
install-gem: build
	@gem install grafanatic-*.gem

.PHONY: setup test lint

# Setup your environment
setup:
	@bundle install

# Run unit-tests
test:
	@bundle exec rspec

# Perform linting operations on code
lint:
	@bundle exec rubocop

# Open Pry REPL with gem preloaded to interact with
console:
	@bundle exec pry

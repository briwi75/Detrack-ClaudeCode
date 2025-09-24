# Start SimpleCov before loading application code
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Models', 'lib/detrack/models'
  add_group 'Services', 'lib/detrack/services'
  add_group 'Commands', 'lib/detrack/commands'

  # Set minimum coverage threshold
  minimum_coverage 90

  # Generate multiple report formats
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])
end

require_relative '../lib/detrack'
require_relative 'support/test_data_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed

  # Filter out network requests during testing
  config.before(:each) do
    # Allow local connections but prevent actual network calls in tests
    # Tests should use mocked HTTP responses
  end
end
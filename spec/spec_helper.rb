$LOAD_PATH.unshift(File.join(File.expand_path('..', __dir__), 'lib'))

require 'pry-byebug'
require 'cryptostream'

Dir['./spec/helpers/**/*.rb'].sort.each { |f| require f }

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  config.expose_dsl_globally = true

  Kernel.srand config.seed
end

module Cryptostream
  # @abstract
  class Plugin
    # Called when a new block is added to the main chain.
    #
    # @param block [AdapterBlock] currency adapter's representation of the block
    # @param data [Hash] supplementary data provided by plugins
    def block_added(block, data); end

    # Called when a new block should be removed. A reason is provided to identify if the removal
    # was due to being :orphaned or :pruned
    #
    # @param block [AdapterBlock] adapter's representation of the block
    # @param data [Hash] supplementary data provided by plugins. Always includes reason for
    #   removal in `reason` key as :orphaned or :pruned
    def block_removed(block, data); end

    # Called when an unexpected error occurs within the steam process to allow the plugin to
    # determine how to handle it.
    #
    # @param error [StandardError] error that was raised
    # @return [Boolean] if plugin wants the process to retry. true will have the caller retry,
    #   false will reraise the error and crash the process
    def handle_error(_error)
      false
    end

    # NOTE: Used internally by Cryptostream. Plugin implementations should not be modifying this, at
    # least without calling super.
    def internal_set_currency_config(currency_config)
      @currency_config = currency_config
    end

    private

    attr_reader :currency_config

    def rpc
      currency_config.rpc
    end

    def store
      currency_config.store
    end
  end
end

require 'cryptostream/plugin/lambda'
require 'cryptostream/plugin/log_blocks'
require 'cryptostream/plugin/store_blocks'

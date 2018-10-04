module Cryptostream
  module Stream
    class Blocks
      RETRY_DELAY = 2

      def initialize(configuration:, store: nil, plugins: [], logger: Cryptostream.logger)
        @configuration = configuration
        @currency = Cryptostream::Currency.get(configuration, store: store)
        @logger = logger
        @plugins = initialize_plugins(plugins)
      end

      def run
        loop do
          begin
            remote_tip = adapter.latest_block
            reconcile_history(remote_tip) if remote_tip
          rescue AssertionError => e
            logger.error("Assertion Error: #{e.message}. Retrying in #{RETRY_DELAY}s...")
          rescue StandardError => e
            raise if !handle_error?(e)
          rescue SignalException
            break # Capture Ctrl-C and exit the infinite loop
          end

          # Sleep after each loop to allow new blocks to be mined before checking again
          sleep RETRY_DELAY
        end
      rescue StandardError => e
        logger.error("Unexpected Error: #{e.class} #{e.message}. Stopping...")
        logger.error(e.backtrace)
      end

      def reconcile_history(new_block)
        if chain_tip.nil?
          add_genesis_block
          return
        end

        return if block_in_history?(new_block)

        if parent_in_history?(new_block)
          rollback_until_block(new_block)
          add_block(new_block)
          return
        end

        backfill_and_add_block(new_block)
      end

      private

      attr_reader :configuration, :logger, :currency, :plugins

      def initialize_plugins(plugins)
        plugins.map do |plug_class_or_instance|
          plug = if plug_class_or_instance.is_a?(Plugin)
                   plug_class_or_instance
                 else
                   plug_class_or_instance.new
                 end

          plug.internal_set_currency_config(currency)

          plug
        end
      end

      def handle_error?(error)
        # Allow any of the plugins to short-circuit that plugin execution progress if they say they
        # have handled the error.
        plugins.reduce(false) { |handled, plugin| handled || plugin.handle_error(error) }
      end

      def backfill_and_add_block(block)
        tip = chain_tip

        if adapter.no_reorgs_expected?(tip, block)
          next_block = adapter.next_block(tip)
          if !adapter.child_block?(next_block, tip)
            raise AssertionError, "Next block is not a child of the chain tip"
          end
        else
          next_block = adapter.block_parent(block)
          if next_block.nil?
            raise AssertionError, "Expected to find parent of block but was not able to fetch one"
          end
        end

        prune_history(next_block) if prune_history?(next_block, tip)
        reconcile_history(next_block)
        reconcile_history(block)
      end

      def add_genesis_block
        add_block(adapter.genesis_block)
      end

      def add_block(block)
        data = {}
        plugins.each { |plugin| plugin.block_added(block.original, data) }
      end

      def remove_block(block, reason)
        data = { reason: reason }
        plugins.each { |plugin| plugin.block_removed(block.original, data) }
      end

      def prune_history?(next_block, tip)
        return if tip.nil?
        return if block_retention.nil?

        tip.number > next_block.number - block_retention
      end

      # This method will prune old blocks from history based on the configured block_retention
      # value.
      #
      # This isn't a great implementation, and would be vastly simplified by exposing
      # a block_by_number method on the store or some other bulk operation, but this keeps the
      # external API simpler.
      def prune_history(target_block)
        min_height = target_block.number - (block_retention || 0)

        # This code walks back up the chain using the previous hash of each block until it finds the
        # the first block that is less than the min height. This is the first one we
        # want to delete.
        block_to_remove = store.block_by_hash(target_block.previous_hsh)
        until block_to_remove.nil? || block_to_remove.number < min_height
          block_to_remove = store.block_by_hash(block_to_remove.previous_hsh)
        end

        # Now that we have the block less than the min height, delete all of it's parents
        until block_to_remove.nil?
          remove_block(block_to_remove, :pruned)
          block_to_remove = store.block_by_hash(block_to_remove.previous_hsh)
        end
      end

      def rollback_until_block(block)
        remove_block(chain_tip, :orphaned) until adapter.child_block?(block, chain_tip)
      end

      def block_in_history?(block)
        block_hsh_in_history?(block.hsh)
      end

      def parent_in_history?(block)
        block_hsh_in_history?(block.previous_hsh)
      end

      def block_hsh_in_history?(hsh)
        !store.block_by_hash(hsh).nil?
      end

      def chain_tip
        store.chain_tip
      end

      def block_retention
        configuration[:block_retention]
      end

      def adapter
        currency.adapter
      end

      def store
        currency.store
      end

      def rpc
        currency.rpc
      end
    end
  end
end

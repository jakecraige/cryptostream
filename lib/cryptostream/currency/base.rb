module Cryptostream
  module Currency
    class Base
      attr_reader :configuration
      attr_writer :store

      def initialize(configuration, store: nil)
        @configuration = configuration
        @store = store
      end

      def store
        # self.class reference needed for subclass to reference proper namespace
        @store ||= self.class::MemoryStore.new(
          starting_block_height: configuration[:starting_block_height],
          rpc: rpc
        )
      end

      def adapter
        # self.class reference needed for subclass to reference proper namespace
        @adapter ||= self.class::Adapter.new(rpc: rpc)
      end

      # Must be overridden by subclass if not using an embedded RPC client implementation
      def rpc
        # self.class reference needed for subclass to reference proper namespace
        @rpc ||= self.class::RPC.new(rpc_url: configuration.fetch(:rpc_uri))
      end
    end
  end
end

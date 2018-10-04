module Cryptostream
  class Plugin
    class Lambda < Plugin
      def initialize(lambda_handlers)
        @lambda_handlers = lambda_handlers
      end

      def block_added(block, data)
        lambda_handlers[:on_block_added]&.call(block, data)
      end

      def block_removed(block, data)
        lambda_handlers[:on_block_removed].call(block, data)
      end

      private

      attr_reader :lambda_handlers
    end
  end
end

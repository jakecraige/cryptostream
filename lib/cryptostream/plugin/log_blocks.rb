module Cryptostream
  class Plugin
    class LogBlocks < Plugin
      def block_added(block, _data)
        log_block("Adding Block", block)
      end

      def block_removed(block, data)
        log_block("Removing Block (#{data[:reason]})", block)
      end

      private

      def log_block(message, block)
        puts "#{message} #{store.block_number(block)} (#{store.block_hash(block)})"
      end
    end
  end
end

module Cryptostream::Currency
  class Bitcoin
    class MemoryStore < Cryptostream::Store::Memory
      def initialize_starting_block(rpc, height)
        rpc.getblockbynumber(height, true)
      end

      def block_hash(block)
        block["hash"]
      end

      def previous_hash(block)
        block["previousblockhash"]
      end

      def block_number(block)
        block["height"]
      end
    end
  end
end

module Cryptostream::Currency
  class Ethereum
    class MemoryStore < Cryptostream::Store::Memory
      def initialize_starting_block(rpc, height)
        rpc.block_by_number(height)
      end

      def block_hash(block)
        block.hsh
      end

      def previous_hash(block)
        block.parent_hsh
      end

      def block_number(block)
        block.number
      end
    end
  end
end

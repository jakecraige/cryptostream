module Cryptostream::Currency
  class Stellar
    class MemoryStore < Cryptostream::Store::Memory
      def initialize_starting_block(rpc, height)
        rpc.ledger(height)
      end

      def block_hash(block)
        block["hash"]
      end

      def previous_hash(block)
        block["prev_hash"]
      end

      def block_number(block)
        block["sequence"]
      end
    end
  end
end

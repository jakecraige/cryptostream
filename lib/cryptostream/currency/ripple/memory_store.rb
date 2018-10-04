module Cryptostream::Currency
  class Ripple
    class MemoryStore < Cryptostream::Store::Memory
      def initialize_starting_block(rpc, height)
        rpc.ledger(height)
      end

      def block_hash(block)
        block["ledger_hash"]
      end

      def previous_hash(block)
        block["parent_hash"]
      end

      def block_number(block)
        block["ledger_index"]
      end
    end
  end
end

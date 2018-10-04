module Cryptostream::Currency
  class Stellar
    class Adapter < Cryptostream::Adapter::Common
      def latest_block
        to_generic(rpc.latest_ledger)
      end

      def block_parent(block)
        block_by_number(block.number - 1)
      end

      def genesis_block
        block_by_number(1)
      end

      private

      def confs_to_finalization
        1
      end

      def block_by_number(number)
        to_generic(rpc.ledger(number))
      end

      def to_generic(rpc_block)
        return if rpc_block.nil?

        Cryptostream::GenericBlock.new(
          number: rpc_block["sequence"],
          hsh: rpc_block["hash"],
          previous_hsh: rpc_block["prev_hash"],
          original: rpc_block
        )
      end
    end
  end
end

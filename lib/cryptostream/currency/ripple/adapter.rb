module Cryptostream::Currency
  class Ripple
    # NOTE(jake): This could subclass Stellar::Adapter and only have the `to_generic` implementation
    # but I've opted to redefine
    class Adapter < Cryptostream::Adapter::Common
      def latest_block
        to_generic(rpc.latest_ledger)
      end

      def block_parent(block)
        block_by_number(block.number - 1)
      end

      def genesis_block
        # This number is from a random reddit post. I'm not sure what the real first block is but
        # it's not 0 or 1 or the public data source API does not have it if so.
        block_by_number(32_570)
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
          number: rpc_block["ledger_index"],
          hsh: rpc_block["ledger_hash"],
          previous_hsh: rpc_block["parent_hash"],
          original: rpc_block
        )
      end
    end
  end
end

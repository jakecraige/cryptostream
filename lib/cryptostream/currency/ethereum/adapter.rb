module Cryptostream::Currency
  class Ethereum
    class Adapter < Cryptostream::Adapter::Common
      private

      def confs_to_finalization
        50
      end

      def latest_block_height
        rpc.current_block_number
      end

      def block_by_number(number)
        to_generic(rpc.block_by_number(number))
      end

      def block_by_hash(hsh)
        to_generic(rpc.block_by_hash(hsh))
      end

      def to_generic(rpc_block)
        return if rpc_block.nil?

        Cryptostream::GenericBlock.new(
          number: rpc_block.number,
          hsh: rpc_block.hsh,
          previous_hsh: rpc_block.parent_hsh,
          original: rpc_block
        )
      end
    end
  end
end

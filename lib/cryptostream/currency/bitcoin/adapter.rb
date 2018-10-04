module Cryptostream::Currency
  class Bitcoin
    class Adapter < Cryptostream::Adapter::Common
      private

      def confs_to_finalization
        6
      end

      def latest_block_height
        rpc.getblockcount
      end

      def block_by_number(number)
        block_by_hash(rpc.getblockhash(number))
      end

      def block_by_hash(hsh)
        to_generic(rpc.getblock(hsh, true))
      end

      def to_generic(rpc_block)
        return if rpc_block.nil?

        Cryptostream::GenericBlock.new(
          number: rpc_block["height"],
          hsh: rpc_block["hash"],
          previous_hsh: rpc_block["previousblockhash"],
          original: rpc_block
        )
      end
    end
  end
end

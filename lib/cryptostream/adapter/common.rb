module Cryptostream
  module Adapter
    class Common < Base
      def initialize(rpc:)
        @rpc = rpc
      end

      # @returns [Integer]
      def latest_block_height
        raise NotImplementedError
      end

      # @returns [Integer]
      def confs_to_finalization
        raise NotImplementedError
      end

      # @returns [GenericBlock]
      def block_by_number(_number)
        raise NotImplementedError
      end

      # Required if you do not implement block_parent on the sublcass
      #
      # @returns [GenericBlock]
      def block_by_hash(_hsh)
        raise NotImplementedError
      end

      def latest_block
        block_by_number(latest_block_height)
      end

      def genesis_block
        block_by_number(0)
      end

      def no_reorgs_expected?(local_tip, remote_tip)
        remote_tip.number - local_tip.number > confs_to_finalization
      end

      def next_block(block)
        block_by_number(block.number + 1)
      end

      def block_parent(block)
        block_by_hash(block.previous_hsh)
      end

      def child_block?(child_block, parent_block)
        parent_block.hsh == child_block.previous_hsh
      end

      private

      attr_reader :rpc
    end
  end
end

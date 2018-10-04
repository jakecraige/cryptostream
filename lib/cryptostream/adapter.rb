module Cryptostream
  module Adapter
    class Base
      # @returns [GenericBlock]
      def latest_block
        raise NotImplementedError
      end

      # @returns [GenericBlock]
      def genesis_block
        raise NotImplementedError
      end

      # @param local_tip [GenericBlock]
      # @param remote_tip [GenericBlock]
      def no_reorgs_expected?(_local_tip, _remote_tip)
        raise NotImplementedError
      end

      # @param next_block [GenericBlock]
      def next_block(_block)
        raise NotImplementedError
      end

      # @param param [GenericBlock]
      # @returns [GenericBlock]
      def block_parent(_block)
        raise NotImplementedError
      end

      # @param child_block [GenericBlock]
      # @param parent_block [GenericBlock]
      def child_block?(_child_block, _parent_block)
        raise NotImplementedError
      end
    end
  end
end

require 'cryptostream/adapter/common'

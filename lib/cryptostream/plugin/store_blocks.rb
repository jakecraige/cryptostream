module Cryptostream
  class Plugin
    # If your storage implements the `add_block` and `remove_block` method this plugin can be used
    # as an easy way to have it start storing data without having to implement your own plugin.
    class StoreBlocks < Plugin
      def block_added(block, _data)
        store.add_block(block)
      end

      def block_removed(block, data)
        store.remove_block(block, data[:reason])
      end
    end
  end
end

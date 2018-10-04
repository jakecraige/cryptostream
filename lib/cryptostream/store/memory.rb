module Cryptostream
  module Store
    class Memory < Base
      attr_reader :blocks, :blocks_map

      def initialize(starting_block_height: nil, rpc: nil)
        @blocks = []
        @blocks_map = {}

        if starting_block_height && rpc
          starting_block = initialize_starting_block(rpc, starting_block_height)
          if starting_block.nil?
            raise AssertionError, "Starting block #{starting_block_height} not found"
          end

          add_block(starting_block)
        end
      end

      # Optional: Initialize starting block from the initialization parameters. It should fetch the
      # block from the height and return it.
      #
      # By prepopulating the first block that will be returned by the chain_tip method, we
      # can have the sync start from a non-genesis block.
      #
      # @returns [AdapterBlock]
      def initialize_starting_block
        nil
      end

      def block_hash(_block)
        raise NotImplementedError
      end

      def previous_hash(_block)
        raise NotImplementedError
      end

      def block_number(_block)
        raise NotImplementedError
      end

      def add_block(block)
        blocks << block
        blocks_map[block_hash(block)] = block
      end

      def remove_block(block, _reason)
        hsh = block_hash(block)
        mem_block = blocks_map[hsh]
        blocks.delete(mem_block)
        blocks_map.delete(hsh)
      end

      def chain_tip
        to_generic(blocks.last)
      end

      def block_by_hash(hsh)
        to_generic(blocks_map[hsh])
      end

      private

      attr_reader :starting_block_height, :rpc

      def to_generic(block)
        return if block.nil?

        Cryptostream::GenericBlock.new(
          number: block_number(block),
          hsh: block_hash(block),
          previous_hsh: previous_hash(block),
          original: block
        )
      end
    end
  end
end

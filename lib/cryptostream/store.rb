module Cryptostream
  module Store
    class Base
      # Retrieve main chain tip from storage
      #
      # @returns [GenericBlock]
      def chain_tip
        raise NotImplementedError
      end

      # Retrieve block from storage using it's hash
      #
      # @params hsh [String]
      # @returns [GenericBlock]
      def block_by_hash(_hsh)
        raise NotImplementedError
      end
    end
  end
end

require 'cryptostream/store/memory'

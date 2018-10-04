module Cryptostream::Currency
  class Ethereum
    # Representation of an ERC-721 transfer. ERC-721 transfers events are actually just ERC-20. This
    # extends the base implementation with specific methods for features ERC-721 adds.
    #
    # We override the default topic check since CryptoKitties doesn't implement their Transfer event
    # with the values being indexed, so we handle that separately.
    #
    # Eventually this class should live in ethereum-ruby-api instead of this project and we can
    # design this class accordingly.
    class ERC721Transfer < ERC20Transfer
      ZERO_ADDRESS = "0000000000000000000000000000000000000000".freeze

      def initialize(log, currency)
        # skip topic size check since CryptoKitties doesn't index it's transfers LOL
        @contract_address = log.address
        @block_hash = log.block_hsh
        @block_number = log.block_number
        @transaction_hash = log.transaction_hsh
        @transaction_index = log.transaction_index
        @topics = log.topics
        @data = log.data
        @currency = currency
        @log_index = log.log_index
      end

      # @return [Integer] unique id of the token
      def token_id
        (topics[3] || split_data[2]).to_i(16)
      end

      def from_address
        normalize_address(topics[1] || split_data[0])
      end

      def to_address
        normalize_address(topics[2] || split_data[1])
      end

      # True when the NFT was created with this event
      def created?
        from_address == ZERO_ADDRESS
      end

      # True when the NFT was destroyed with this event
      def destroyed?
        to_address == ZERO_ADDRESS
      end

      def split_data
        @split_data ||= data.scan(/.{64}/)
      end
    end
  end
end

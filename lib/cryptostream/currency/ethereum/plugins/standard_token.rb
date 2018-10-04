module Cryptostream::Currency
  class Ethereum
    class StandardTokenPlugin < Cryptostream::Plugin
      TRANSFER_TOPIC = CB::Ethereum::Util.keccak256('Transfer(address,address,uint256)')

      def initialize(tokens)
        # First, handle allowing the token addresses to be in basically any format and not cause
        # problems with them not matching what we expect.
        tokens.transform_values! do |address|
          CB::Ethereum::Util.sanitize_address(address)
        end

        # Next build and cache the array of token addressees and mapping from address to currency
        @tokens = { addresses: tokens.values, address_to_currency: tokens.invert }
      end

      def block_added(block, data)
        data[self.class::STANDARD_NAME] = transfers_for_block(block)
      end

      private

      attr_reader :tokens

      def transfers_for_block(block)
        addresses = tokens[:addresses]
        return [] if addresses.empty?

        logs = rpc.get_transaction_logs(block.number, block.number, addresses, [TRANSFER_TOPIC])

        logs.map do |log|
          currency = tokens[:address_to_currency][log.address]
          self.class::TRANSFER_CLASS.new(log, currency)
        end
      end
    end
  end
end

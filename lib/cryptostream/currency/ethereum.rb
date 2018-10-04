module Cryptostream
  module Currency
    class Ethereum < Base
      def rpc
        @rpc ||= CB::Ethereum::Client.create(
          rpc_endpoint: configuration.fetch(:rpc_uri),
          # The implementation only matters for custom calls that are Parity specific like tracing.
          # Since we're not using any of these, it's reasonable to provide the default here.
          node_implementation: configuration.fetch(:rpc_implementation, :parity)
        )
      end
    end
  end
end

require 'cryptostream/currency/ethereum/adapter'
require 'cryptostream/currency/ethereum/memory_store'
require 'cryptostream/currency/ethereum/erc20_transfer'
require 'cryptostream/currency/ethereum/erc721_transfer'
require 'cryptostream/currency/ethereum/plugins/standard_token'
require 'cryptostream/currency/ethereum/plugins/erc20'
require 'cryptostream/currency/ethereum/plugins/erc721'

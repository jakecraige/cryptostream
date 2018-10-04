module Cryptostream
  module Currency
    class Bitcoin < Base
      def rpc
        @rpc ||= self.class::RPC.make_client(rpc_url: configuration.fetch(:rpc_uri))
      end
    end
  end
end

require 'cryptostream/currency/bitcoin/adapter'
require 'cryptostream/currency/bitcoin/memory_store'
require 'cryptostream/currency/bitcoin/rpc'
require 'cryptostream/currency/bitcoin/plugins/transactions'

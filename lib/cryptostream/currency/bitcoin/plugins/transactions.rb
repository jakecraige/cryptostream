module Cryptostream::Currency
  class Bitcoin
    class TransactionsPlugin < Cryptostream::Plugin
      def block_added(block, data)
        data[:transactions] = rpc.getblocktransactions(block)
      end
    end
  end
end

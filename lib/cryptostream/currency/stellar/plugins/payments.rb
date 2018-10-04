module Cryptostream::Currency
  class Stellar
    class PaymentsPlugin < Cryptostream::Plugin
      def block_added(block, data)
        data[:payments] = rpc.ledger_payments(block["sequence"])
      end
    end
  end
end

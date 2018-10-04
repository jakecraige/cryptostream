module Cryptostream
  module Currency
    class Stellar < Base
    end
  end
end

require 'cryptostream/currency/stellar/adapter'
require 'cryptostream/currency/stellar/memory_store'
require 'cryptostream/currency/stellar/payment'
require 'cryptostream/currency/stellar/rpc'
require 'cryptostream/currency/stellar/plugins/payments'

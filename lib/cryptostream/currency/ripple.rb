module Cryptostream
  module Currency
    class Ripple < Base
    end
  end
end

require 'cryptostream/currency/ripple/adapter'
require 'cryptostream/currency/ripple/memory_store'
require 'cryptostream/currency/ripple/rpc'

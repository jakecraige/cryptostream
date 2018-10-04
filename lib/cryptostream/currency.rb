module Cryptostream
  module Currency
    def self.get(configuration, store: nil)
      ticker = configuration.fetch(:ticker)
      currency_class = class_for_ticker(ticker)
      currency_class.new(configuration, store: store)
    end

    def self.class_for_ticker(ticker)
      case ticker
      when :eth, :etc
        Cryptostream::Currency::Ethereum
      when :btc, :ltc, :bch
        Cryptostream::Currency::Bitcoin
      when :xlm
        Cryptostream::Currency::Stellar
      when :xrp
        Cryptostream::Currency::Ripple
      else
        raise StandardError, "Unsupported ticker: #{ticker}"
      end
    end
  end
end

require 'cryptostream/currency/base'
require 'cryptostream/currency/bitcoin'
require 'cryptostream/currency/ethereum'
require 'cryptostream/currency/ripple'
require 'cryptostream/currency/stellar'

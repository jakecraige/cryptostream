require 'cb/ethereum'

module Cryptostream
  class AssertionError < StandardError; end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end

require 'cryptostream/adapter'
require 'cryptostream/generic_block'
require 'cryptostream/plugin'
require 'cryptostream/store'
require 'cryptostream/currency'
require 'cryptostream/stream'
require 'cryptostream/version'

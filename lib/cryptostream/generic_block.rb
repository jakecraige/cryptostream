module Cryptostream
  class GenericBlock
    attr_reader :number, :hsh, :previous_hsh, :original

    def initialize(number:, hsh:, previous_hsh:, original:)
      @number = number
      @hsh = hsh
      @previous_hsh = previous_hsh
      @original = original
    end
  end
end

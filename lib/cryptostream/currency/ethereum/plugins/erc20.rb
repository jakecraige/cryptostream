module Cryptostream::Currency
  class Ethereum
    class ERC20Plugin < StandardTokenPlugin
      STANDARD_NAME = :erc20
      TRANSFER_CLASS = ERC20Transfer
    end
  end
end

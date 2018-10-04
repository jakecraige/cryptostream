module Cryptostream::Currency
  class Ethereum
    class ERC721Plugin < StandardTokenPlugin
      STANDARD_NAME = :erc721
      TRANSFER_CLASS = ERC721Transfer
    end
  end
end

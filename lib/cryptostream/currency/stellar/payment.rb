module Cryptostream::Currency
  class Stellar
    PAYMENT_FIELDS = %i[
      id
      paging_token
      source_account
      type
      type_i
      created_at
      transaction_hash
      asset_type
      asset_code
      asset_issuer
      from
      to
      amount
      starting_balance
      funder
      account
    ].freeze

    Payment = Struct.new(*PAYMENT_FIELDS) do
      def initialize(hash)
        hash.each do |key, value|
          method_name = "#{key}="
          send(method_name, value) if respond_to?(method_name)
        end
      end
    end
  end
end

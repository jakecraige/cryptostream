require 'faraday'
require 'faraday_middleware'

module Cryptostream::Currency
  class Stellar
    class RPC
      attr_reader :client

      def initialize(rpc_url:)
        @client = Faraday.new(url: rpc_url) do |builder|
          builder.response :json
          builder.request :json
          builder.adapter Faraday.default_adapter
        end
      end

      def latest_ledger
        response = client.get("ledgers", limit: 1, order: :desc)
        body = get_body!(response)
        body["_embedded"]["records"].first
      end

      def ledger(sequence_number)
        response = client.get("ledgers/#{sequence_number}")
        get_body!(response)
      end

      # NOTE(jake): This only gets the first page currently. A complete implementation would respect
      # paging parameters and request all payments in the ledger.
      #
      # @return [Array<Payment>] payments in the ledger
      def ledger_payments(sequence_number)
        response = client.get("ledgers/#{sequence_number}/payments")
        body = get_body!(response)
        body["_embedded"]["records"].map { |payment| Payment.new(payment) }
      end

      def get_body!(response)
        if response.success?
          response.body
        else
          response_summary = {
            url: response.env.url,
            status: response.status,
            headers: response.headers,
            body: response.body
          }
          raise Faraday::Error::ClientError, response_summary
        end
      end
    end
  end
end

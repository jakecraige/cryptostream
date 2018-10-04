require 'faraday'
require 'faraday_middleware'

module Cryptostream::Currency
  class Ripple
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
        response = client.get("ledgers")
        get_body!(response)["ledger"]
      end

      def ledger(ledger_index_or_hash)
        response = client.get("ledgers/#{ledger_index_or_hash}")
        get_body!(response)["ledger"]
      end

      def get_body!(response)
        if response.success? && response.body["result"] == "success"
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

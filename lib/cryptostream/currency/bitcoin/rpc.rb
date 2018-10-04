require 'faraday'
require 'faraday_middleware'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

# Bitcoin RPC has a limited work queue depth that defaults to 16. Default concurrency is 200 which
# can exhaust it easily and cause it to error out.
HYDRA = Typhoeus::Hydra.new(max_concurrency: 16)

module Cryptostream::Currency
  class Bitcoin
    # Interface to Bitcoin/Bitcoin Cash/Litecoin JSON-RPC
    # Copied from Wallace Repository
    class RPC
      class BitcoinRPCError < StandardError; end
      class UpstreamError < BitcoinRPCError; end

      attr_reader :client

      # Default constructor
      #
      # @param faraday_client [Faraday::Client] client used to make requests
      def initialize(faraday_client:)
        @client = faraday_client
      end

      # @return [Wallace::Clients::BitcoinRPC] client initialized using environment variables
      def self.make_client(rpc_url:)
        connection = get_connection(rpc_url: rpc_url)
        new(faraday_client: connection)
      end

      def self.get_connection(rpc_url:)
        Faraday.new(url: rpc_url, parallel_manager: HYDRA) do |builder|
          builder.response :json
          builder.request :json
          builder.adapter :typhoeus
        end
      end

      # Given a hash, it gets info on the block
      # https://bitcoin.org/en/developer-reference#getblock
      #
      # @param hash [String] the hash of the block
      # @param verbosity [Integer] the verbosity of the response
      # @return [Object,nil] an JSON representation of an block
      def getblock(hash, verbosity)
        rpc_call('getblock', hash, verbosity)
      end

      def getblockhash(height)
        rpc_call('getblockhash', height)
      end

      def getblockcount
        rpc_call('getblockcount')
      end

      def getblockbynumber(number, verbosity)
        hsh = getblockhash(number)
        getblock(hsh, verbosity)
      end

      # Given a transaction_hsh and decoded boolean, it requests the JSON representation of
      # a transaction. Will only work on the node's own txs or historic transactions if the `txindex`
      # option is enabled (our nodes have this enabled by default).
      # https://bitcoin.org/en/developer-reference#getrawtransaction
      #
      # @param transaction_hsh [String] the txid of the transaction
      # @param decoded [Int] 1 or 0, when 1, returns decoded json transaction
      # @raises [BitcoinRPCError] if transaction cannot be found or node errors
      # @return [Hash] the transaction
      def getrawtransaction(tx_hsh, decoded = 1)
        rpc_call('getrawtransaction', tx_hsh, decoded)
      end

      def getblocktransactions(rpc_block)
        # Cannot get transactions for genesis block
        return [] if rpc_block["height"] == 0

        tx_responses = []
        client.in_parallel do
          rpc_block["tx"].each do |hsh|
            # Can't call getrawtransaction here without it breaking the parrallel stuff for some
            # reason.
            data = rpc_params('getrawtransaction', hsh, 0)
            tx_responses << client.post('/', data)
          end
        end

        tx_responses.map do |response|
          tx_hex = handle_rpc_response(response)
          ::Bitcoin::P::Tx.new([tx_hex].pack("H*"))
        end
      rescue Faraday::Error => e
        raise UpstreamError, e.message
      end

      def rpc_params(method, *args)
        { id: 'jsonrpc', method: method, params: args }
      end

      # Execute remote procedure method passing in args.
      #
      # @param method [String] name of remote procedure to invoke
      # @param args [Array] parameters to pass to remote procedure
      def rpc_call(method, *args)
        data = rpc_params(method, *args)

        response = client.post('/', data)

        handle_rpc_response(response)
      rescue Faraday::Error => e
        raise UpstreamError, e.message
      end

      def handle_rpc_response(response)
        if response.body.nil?
          case response.status
          when 500...600
            response_summary = {
              status: response.status,
              headers: response.headers,
              body: response.body
            }
            raise Faraday::Error::ClientError, response_summary
          else
            raise BitcoinRPCError, "Response body is empty, status #{response.status}"
          end
        end

        raise BitcoinRPCError, response.body['error'] if response.body['error']

        response.body['result']
      end
    end
  end
end

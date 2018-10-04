module Cryptostream::Currency
  class Ethereum
    # Representation of an ERC-20 transfer. Source from Macbeth repository.
    class ERC20Transfer
      # [Integer] The expected number of topics in the event log
      EXPECTED_NUM_TOPICS = 3

      # [String] The address of the contract the event originated from
      attr_reader :contract_address
      # [String] Hash of the block that mined the event
      attr_reader :block_hash
      # [Integer] The number of the block that was mined
      attr_reader :block_number
      # [String] Hash of the transaction that produced the event
      attr_reader :transaction_hash
      # [Integer] Index of the transaction in the block
      attr_reader :transaction_index
      # [Array<String>] Topics associated with the event
      attr_reader :topics
      # [String] Data associated with the event
      attr_reader :data
      # [String] Name of the currency associated with the contract
      attr_reader :currency
      # [Integer] Index of the event in the block that it is included in
      attr_reader :log_index

      # Default constructor
      #
      # @param log [Ethereum::Protocol::TxLog] event log
      def initialize(log, currency)
        unless log.is_a? CB::Ethereum::Protocol::TxLog
          raise ArgumentError,
                "Expected type CB::Ethereum::Protocol::TxLog for log, found #{log.class.name}"
        end
        if log.topics.size != EXPECTED_NUM_TOPICS
          raise ArgumentError,
                "Expected #{EXPECTED_NUM_TOPICS} topics, found #{log.topics.size}"
        end

        @contract_address = log.address
        @block_hash = log.block_hsh
        @block_number = log.block_number
        @transaction_hash = log.transaction_hsh
        @transaction_index = log.transaction_index
        @topics = log.topics
        @data = log.data
        @currency = currency
        @log_index = log.log_index
      end

      # @return [String] source address of the transfer event
      def from_address
        normalize_address(@topics[1])
      end

      # @return [String] destination address of the transfer event
      def to_address
        normalize_address(@topics[2])
      end

      # @return [Integer] raw amount of currency transferred
      def value
        @data.to_i(16)
      end

      def to_h
        {
          contract_address: contract_address,
          block_hash: block_hash,
          transaction_hash: transaction_hash,
          currency: currency,
          to: to_address,
          from: from_address,
          value: value,
          log_index: log_index
        }
      end

      # Return given address in a normalized form.
      #
      # normalize_address('0x000000000000000000000000ae19990e3db5901554b2e08fdb3973659863f816')
      # > 'ae19990e3db5901554b2e08fdb3973659863f816'
      #
      # @param address [String] address
      # @return [String]
      def normalize_address(address)
        # Remove leading zeros from the address
        address = address.to_i(16).to_s(16)
        CB::Ethereum::Util.sanitize_address(address)
      end
    end
  end
end

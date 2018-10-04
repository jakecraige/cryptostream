# Cryptostream

*Warning: This project was created for a hackathon and is not production ready and has absolutely no
tests backing it up. This can be used as a reference to build you own, but I make no guarantees
about this actually working correctly if you do not evaluate it yourself.*

Cryptostream is gem designed to make getting a stream of blocks from arbitrary blockchains easy.
Right now it supports BTC, BCH, LTC, ETH, ETC, XLM, and XRP.

## Usage

The example below shows the most basic usage of this library, leaning on defaults like an in-memory
store to keep track of state. In a production implementation you will more likely be implementing
a subclass of `Cryptostream::Store::Base` to persist data.

### Streaming Blocks

This sample will log all blocks and works with every chain this library supports.

```ruby
streamer = Cryptostream::Stream::Blocks.new(
  configuration: {
    ticker: :eth,
    rpc_uri: "https://mainnet.infura.io/",
    block_retention: 50, # optional, constrains memory usage of default memory store
  },
  plugins: [
    # NOTE: The class of the block received here is specific to the adapter which is chosen from the
    # currency configuration provided above. You'll need to reference further docs on each adapter
    # to know what to expect here.
    Cryptostream::Plugin::Lambda.new(
      on_block_added: ->(block, _data) { puts "Added block: #{block.number} (#{block.hsh})" },
      on_block_removed: lambda do |block, data|
        puts "Removed block (#{data[:reason]}): #{block.number} (#{block.hsh})"
      end
    ),
    Cryptostream::Plugin::StoreBlocks
  ]
)
streamer.run
```

### Streaming Ethereum Token Transfers

This sample will log all blocks and specified ERC20 and ERC721 transfers.

```ruby
streamer = Cryptostream::Stream::Blocks.new(
  configuration: {
    ticker: :eth,
    rpc_uri: "https://mainnet.infura.io/",
    starting_block_height: 6222278 # optional: only supported with default memory store
  },
  plugins: [
    Cryptostream::Currency::Ethereum::ERC20Plugin.new(
      ZRX: "0xe41d2489571d322189246dafa5ebde1f4699f498"
    ),
    Cryptostream::Currency::Ethereum::ERC721Plugin.new(
      CryptoKitties: "0x06012c8cf97bead5deae237070f9587f8e7a266d"
    ),
    Cryptostream::Plugin::Lambda.new(
      on_block_added: lambda do |block, transfers|
        puts "Added block: #{block.number} (#{block.hsh})"

        transfers[:erc20].each do |t|
          puts "  #{t.currency} Transfer | Amount: #{t.value / 1e18}, Hsh: #{t.transaction_hash}"
        end

        transfers[:erc721].each do |t|
          type = "Transfer"
          type = "Created" if t.created?
          type = "Destroyed" if t.destroyed?
          puts "  #{t.currency} #{type} | Token ID: #{t.token_id}, Hsh: #{t.transaction_hash}"
        end
      end,

      on_block_removed: lambda do |block, reason|
        puts "Removed block (#{reason}): #{block.number} (#{block.hsh})"
      end
    ),
    Cryptostream::Plugin::StoreBlocks
  ]
)
streamer.run
```

### Streaming Bitcoin/Cash/Lite Transactions

This sample will log all blocks and transactions

```ruby
streamer = Cryptostream::Stream::Blocks.new(
  configuration: {
    ticker: :btc,
    rpc_uri: "https://USERNAME:PASSWORD@BITCOIN_NODE_URL",
    starting_block_height: 1410000, # optional: only supported with default memory store
  },
  plugins: [
    Cryptostream::Currency::Bitcoin::TransactionsPlugin,

    Cryptostream::Plugin::Lambda.new(
      on_block_added: lambda do |block, data|
        puts "Added block: #{block['height']} (#{block['hash']})"
        transactions = data[:transactions]

        if transactions.length > 20
          puts "  Transactions | Too many transactions(#{transactions.length}) to list | Printing first 5..."
          transactions.first(5).each do |tx|
            puts "  Transaction  | #{tx.hash} | Inputs: #{tx.in.length} | Outputs: #{tx.out.length}"
          end
        else
          transactions.each do |tx|
            puts "  Transaction | #{tx.hash} | Inputs: #{tx.in.length} | Outputs: #{tx.out.length}"
          end
        end
      end,

      on_block_removed: lambda do |block, reason|
        puts "Removed block (#{reason}): #{block.number} (#{block.hsh})"
      end
    ),

    Cryptostream::Plugin::StoreBlocks,
  ]
)
streamer.run
```

### Streaming Stellar Payments

This sample will stream and log all Stellar ledgers and payments

```ruby
streamer = Cryptostream::Stream::Blocks.new(
  configuration: {
    ticker: :xlm,
    rpc_uri: "https://horizon.stellar.org",
    starting_block_height: 19733892
  },
  plugins: [
    Cryptostream::Currency::Stellar::PaymentsPlugin,

    Cryptostream::Plugin::Lambda.new(
      on_block_added: lambda do |block, data|
        puts "Added block: #{block['sequence']} (#{block['hash']})"
        payments = data[:payments]

        payments.each do |t|
          case t.type
          when "payment"
            puts "  Payment | #{t.asset_code || 'XLM'} | Type: #{t.asset_type} | Amount: #{t.amount}"
          when "create_account"
            puts "  Account Created | Starting Balance: #{t.starting_balance} | #{t.account}"
          end
        end
      end,

      on_block_removed: lambda do |block, reason|
        puts "Removed block (#{reason}): #{block['sequence']} (#{block['hash']})"
      end
    ),

    Cryptostream::Plugin::StoreBlocks
  ]
)
streamer.run
```

## Integration

To integrate this gem into a project, you need to implement these two interfaces and provide
initialized instances to the stream constructor.

### Cryptostream::Store::Base

```ruby
class Base
  # Retrieve main chain tip from storage
  #
  # @returns [GenericBlock]
  def chain_tip
    raise NotImplementedError
  end

  # Retrieve block from storage using it's hash
  #
  # @params hsh [String]
  # @returns [GenericBlock]
  def block_by_hash(_hsh)
    raise NotImplementedError
  end
end
```

### Cryptostream::Plugin

The plugin is the backbone of this library. As a consumer of the library you at minimum need to
implement one that stores / removes blocks from your storage engine. Outside of that, the world is
your oyster.

All plugins are executed in order and they are allowed to mutate the `data` argument they receive so
that plugins later can access that information. For example, if you implement an ERC20 plugin, you
would use the RPC interface to request information about ERC20 transfers in the block, and set them
on the data object like `data[:erc20_transfers] = transfers`. With that any plugins downstream can
now access that information and react accordingly.

See `lib/cryptostream/plugin` or the custom plugins defined in
`lib/cryptostream/currencies/*/plugins` for examples.

```ruby
class Plugin
  # Called when a new block is added to the main chain.
  #
  # @param block [AdapterBlock] currency adapter's representation of the block
  # @param data [Hash] supplementary data provided by plugins
  def block_added(block, data); end

  # Called when a new block should be removed. A reason is provided to identify if the removal
  # was due to being :orphaned or :pruned
  #
  # @param block [AdapterBlock] adapter's representation of the block
  # @param data [Hash] supplementary data provided by plugins. Always includes reason for
  #   removal in `reason` key as :orphaned or :pruned
  def block_removed(block, data); end

  # Called when an unexpected error occurs within the steam process to allow the plugin to
  # determine how to handle it.
  #
  # @param error [StandardError] error that was raised
  # @return [Boolean] if plugin wants the process to retry. true will have the caller retry,
  #   false will reraise the error and crash the process
  def handle_error(_error)
    false
  end
end
```

## Development

### Setup

To set up the project for local development. Install dependencies with this:

```
make install
```

### Running Tests

You can run the full test suite with the following command:

```
make test
```

You can lint your code using all available linters with:

```
make lint
```

### Dev Testing

A local command line tool can be found at `bin/cryptostream` and used to run against various
testnets and see how the tool behaves.

For BTC, you either need to set `BTC_RPC_URI` in your environment or provide the `--rpc-uri`
option since there is not a publicly accessible bitcoin node we can include by default.

```sh
$ ./bin/cryptostream help
Commands:
  cryptostream help [COMMAND]       # Describe available commands or one specific command
  cryptostream log_bitcoin_transactions TICKER  # Stream and log transactions for bitcoin-like chains
  cryptostream log_blocks TICKER    # Stream and log blocks for TICKER
  cryptostream log_token_transfers  # Stream and log ERC20 and ERC721 transfers for Ethereum

$ ./bin/cryptostream help log_bitcoin_transactions
Usage:
  cryptostream log_bitcoin_transactions TICKER

Options:
  [--rpc-uri=RPC_URI]          # Required: URI of RPC node to communicate with
  [--starting-block-height=N]  # block to start syncing from, Defaults to chain tip.
  [--block-retention=N]        # number of blocks to retain in the store

Stream and log transactions for bitcoin-like chains

$ ./bin/cryptostream help log_blocks
Usage:
  cryptostream log_blocks TICKER

Options:
  [--rpc-uri=RPC_URI]          # URI of RPC node to communicate with. Required for BTC.
  [--starting-block-height=N]  # block to start syncing from
  [--block-retention=N]        # number of blocks to retain in the memory store

Stream and log blocks for TICKER

$ ./bin/cryptostream help log_token_transfers
Usage:
  cryptostream log_token_transfers

Options:
  [--rpc-uri=RPC_URI]          # URI of RPC node to communicate with. Defaults to Infura mainnet
  [--starting-block-height=N]  # block to start syncing from, Defaults to chain tip.
  [--block-retention=N]        # number of blocks to retain in the store

Description:
  `log_token_transfers` will log transfer events for ERC20 and ERC721 tokens on Ethereum.

  The defaults are as such:

  ERC20: ZRX, BAT, WETH, REP, OMG, MKR

  ERC721: CryptoKitties, LucidSight MLB, Gods Unchained, CB Wallet Crypto Swag
```

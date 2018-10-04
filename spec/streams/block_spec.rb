require 'spec_helper'

describe Cryptostream::Stream::Blocks do
  xit "fires block added events starting at the starting hash" do
    stream = Cryptostream::Stream::Blocks.new(
      configuration: { network: :ETH, uri: "a-url" },
      event_handler: {
        on_block_added: ->(block) { puts "Added block: #{block.number} (#{block.hsh})" },
        on_block_removed: lambda do |block, reason|
          puts "Removed block (#{reason}): #{block.number} (#{block.hsh})"
        end
      }
    )

    stream.run
    eth_client = stream.send(:adapter).send(:client)

    # sync genesis
    stream.reconcile_history(eth_client.block_by_number(eth_client.current_block_number))

    # reconcile everything else
    stream.reconcile_history(eth_client.block_by_number(eth_client.current_block_number))

    expect(handler.blocks.length).not_to eq(0)
  end
end

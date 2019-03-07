# coding: utf-8

module Router
  class Base
    def initialize(blockchain:, p2p_enabled: true)
      raise ArgumentError unless blockchain.is_a?(Blockchain::Base)

      @blockchain = blockchain
      @p2p_server = P2pServer.new(blockchain: blockchain, message_handler: self, p2p_enabled: p2p_enabled)
    end

    def subscribe(miner)
      raise ArgumentError unless miner.is_a?(Miner::Base)
      @miner = miner
    end
  
    def push_transaction(tx)
      raise ArgumentError unless tx.is_a?(Blockchain::Transaction)

      @miner.push_transaction(tx) if @miner
      @p2p_server.broadcast_transaction(tx)
    end
  
    def mine_done()
      @p2p_server.broadcast_mined
    end

    def message_handler(data)
      case (data.type)
      when MessageType::BLOCK_CHAIN
        @blockchain.replace_chain(data.payload.map { |o| Block.new(o) })
      when MessageType::TRANSACTION
        @miner.push_transaction(Transaction.new(data.payload)) if @miner
      when MessageType::MINED
        @blockchain.replace_chain(data.payload.map { |o| Block.new(o) })
        @miner.clear_transactions if @miner
      end
    end
  end
end

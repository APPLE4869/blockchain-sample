require 'securerandom'

module Miner
  class Base
    attr_reader :transaction_pool

    def initialize(blockchain:, reward_address:)
      raise ArgumentError unless blockchain.is_a?(Blockchain::Blockchain) && reward_address.is_a?(String)

      @transaction_pool = []
      @blockchain = blockchain
      @reward_address = reward_address
    end
  
    def mine
      mining_start_timestamp = Time.now.to_i
      prev_hash = @blockchain.last_hash
      target = @blockchain.next_difficulty_target
      reward_tx = Blockchain::Transaction.reward_transaction(@reward_address)
      @transaction_pool << reward_tx
  
      nonce = 0
      block = nil
      loop do 
        timestamp = Time.now.to_i
        nonce += 1
        block = Blockchain::Block.new(
          timestamp: timestamp,
          prev_hash: prev_hash,
          difficulty_target: target,
          nonce: nonce,
          transactions: @transaction_pool,
          mining_duration: timestamp - mining_start_timestamp,
        )

        break if block.valid?
      end
  
      @blockchain.add_block(block)
      clear_transactions
    end
  
    # 取引データを追加する
    def push_transaction(tx)
      raise ArgumentError unless tx.is_a?(Blockchain::Transaction)

      unless tx.verify_transaction
        p '署名の検証に失敗しました。'
        return
      end

      @transaction_pool = @transaction_pool.select { |t| t.input && t.input.address != tx.input.address }
      @transaction_pool << tx
      p 'トランザクションを追加しました。'
    end
  
    # トランザクションプールの取引データを初期化する
    def clear_transactions
      @transaction_pool = []
      p 'トランザクションを削除しました。'
    end
  end
end

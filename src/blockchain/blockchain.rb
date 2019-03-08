# coding: utf-8
module Blockchain
  class Base
    attr_reader :blocks

    def initialize
      @blocks = [Block.genesis]
    end

    def add_block(block)
      raise ArgumentError unless block.is_a?(Block)

      return false unless addable_block?(block)

      @blocks << block
      true
    end

    def addable_block?(block)
      raise ArgumentError unless block.is_a?(Block)

      last_block = @blocks.last
      block.prev_hash == last_block.hash && block.timestamp > last_block.timestamp && block.valid?
    end

    def last_hash
      @blocks.last.hash
    end

    def next_difficulty_target
      Base.calc_difficulty_target(@blocks)
    end

    # ブロックチェーンを差し替える
    def replace_chain(new_blocks)
      raise ArgumentError unless new_blocks.all? { |b| b.is_a?(Block) }

      if (new_blocks.length < @blocks.length)
        p "チェーンが短いため無視"
        return
      end
  
      unless (!Base.is_valid_chain(new_blocks))
        p "チェーンが有効でないため無視"
        return
      end
  
      @blocks = new_blocks
      p "ブロックチェーンを更新しました。"
    end

    # 全てのトランザクションを繋げて返す
    def all_transactions
      @blocks.reduce([]) { |a, block| a.concat(block.transactions) }
    end

    def self.calc_difficulty_target(blocks)
      last_block = blocks.last

      return last_block.difficulty_target + 1 if (last_block.mining_duration > MINING_DURATION * 1.2)
      return last_block.difficulty_target - 1 if (last_block.mining_duration < MINING_DURATION * 0.8)
      last_block.difficulty_target
    end
  
    def self.is_valid_chain(blocks)
      return false if blocks.first.to_json != Block.genesis
  
      prev_block = nil
      return chain.all? do |block|
        if (!prev_block)
          prev_block = block
          return true
        end

        if (!block.valid?)
          return false
        end

        if (prev_block.hash != block.prev_hash)
          return false
        end

        prev_block = block
        true
      end
    end
  end
end

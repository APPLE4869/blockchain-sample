require 'digest/sha2'
require 'json'

module Blockchain
  class Block
    attr_reader :timestamp, :difficulty_target, :mining_duration, :prev_hash, :transactions

    def initialize(timestamp:, prev_hash:, difficulty_target:, nonce:, transactions:, mining_duration:)
      # TODO : 後で追加する
      raise ArgumentError unless timestamp.is_a?(Integer) && prev_hash.is_a?(String)

      @timestamp = timestamp
      @prev_hash = prev_hash
      @difficulty_target = difficulty_target
      @nonce = nonce
      @transactions = transactions
      @mining_duration = mining_duration
    end

    def self.genesis
      new(
        timestamp: 0,
        prev_hash: '0' * 64,
        difficulty_target: DIFFICULTY_TARGET,
        nonce: 0,
        transactions: [],
        mining_duration: MINING_DURATION
      )
    end

    def hash
      Digest::SHA256.hexdigest(
        [
          @timestamp,
          @prev_hash,
          @difficulty_target,
          @nonce,
          @transactions,
          @mining_duration
        ].to_s
      )
    end

    def valid?
      "0x#{@hash}".to_i < 2 ** @difficulty_target;
    end

    def to_json(options = {})
      {
        timestamp: @timestamp,
        prev_hash: @prev_hash,
        difficulty_target: @difficulty_target,
        nonce: @nonce,
        transactions: @transactions.map(&:to_json),
        mining_duration: @mining_duration
      }.to_json
    end
  end
end

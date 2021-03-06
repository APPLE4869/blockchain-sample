# coding: utf-8
require 'digest/sha2'
require 'securerandom'
require 'openssl'

module Blockchain
  class Transaction
    attr_reader :input, :outputs

    class Input
      attr_reader :timestamp, :amount, :address, :signature

      def initialize(timestamp:, amount:, address:, signature:)
        raise ArgumentError unless timestamp.is_a?(Integer) && amount.is_a?(Integer) && address.is_a?(String) && signature.is_a?(String)

        @timestamp = timestamp
        @amount = amount
        @address = address
        @signature = signature
      end

      def to_h
        {
          timestamp: @timestamp,
          amount: @amount,
          address: @address,
          signature: Digest::SHA256.hexdigest(@signature)
        }
      end
    end

    class Output
      attr_reader :amount, :address

      def initialize(amount:, address:)
        raise ArgumentError unless amount.is_a?(Integer) && address.is_a?(String)

        @amount = amount
        @address = address
      end

      def to_h
        {
          amount: @amount,
          address: @address
        }
      end
    end

    def initialize
      @id = SecureRandom.uuid
    end
  
    def create_outputs(sender_wallet:, recipient:, amount:)
      raise ArgumentError unless sender_wallet.is_a?(Wallet::Base) && recipient.is_a?(String) && amount.is_a?(Integer)

      balance = sender_wallet.balance

      @outputs = [Output.new(amount: amount, address: recipient)]
      if balance > amount
        @outputs << Output.new(amount: balance - amount, address: sender_wallet.public_key)
      end
    end

    def sign_transaction(sender_wallet)
      raise ArgumentError unless sender_wallet.is_a?(Wallet::Base)

      hash = Digest::SHA256.hexdigest(@outputs.to_json)
      @input = Input.new(
        timestamp: Time.now.to_i,
        amount: sender_wallet.balance(),
        address: sender_wallet.public_key,
        signature: sender_wallet.sign(hash)
      )
    end

    # トランザクションの正当性を検証する
    def verify_transaction
      hash = Digest::SHA256.hexdigest(@outputs.to_json)

      # ここの検証処理は楕円曲線暗号をOpenSSL::PKey::ECで扱う際の特有の処理なので、特に覚える必要はない。
      group = OpenSSL::PKey::EC::Group.new('secp256k1')
      key = OpenSSL::PKey::EC.new(group)
      public_key_bn = OpenSSL::BN.new(@input.address, 16)
      public_key = OpenSSL::PKey::EC::Point.new(group, public_key_bn)
      key.public_key = public_key
      key.dsa_verify_asn1(hash, @input.signature)
    end

    def create_coinbase(recipient)
      raise ArgumentError unless recipient.is_a?(String)

      @outputs = [Output.new(amount: MINING_REWARD, address: recipient)]
      @coinbase = "This is coinbase created at #{Time.now.to_s}"
    end

    def to_h
      {
        id: @id,
        outputs: @outputs.map(&:to_h),
        input: @input.to_h,
        coinbase: @coinbase,
      }
    end

    def self.create_transaction(sender_wallet:, recipient:, amount:)
      raise ArgumentError unless sender_wallet.is_a?(Wallet::Base) && recipient.is_a?(String) && amount.is_a?(Integer)

      tx = Transaction.new
      tx.create_outputs(sender_wallet: sender_wallet, recipient: recipient, amount: amount)
      tx.sign_transaction(sender_wallet)
      tx
    end
  
    def self.reward_transaction(reward_address)
      raise ArgumentError unless reward_address.is_a?(String)

      tx = Transaction.new
      tx.create_coinbase(reward_address)
      tx
    end
  end
end

require 'securerandom'
require 'openssl'

module Wallet
  class Base
    attr_reader :public_key # 取引の際に利用するアドレス

    def initialize(blockchain)
      raise ArgumentError unless blockchain.is_a?(Blockchain::Blockchain)

      @blockchain = blockchain
      # ブロックチェーンでは「楕円曲線暗号」というものを利用して秘密鍵・公開鍵を利用していく。
      # OpenSSL::PKey::EC はRubyで楕円曲線暗号を扱えるクラス。
      # 
      # 楕円曲線暗号の説明
      # @see https://gaiax-blockchain.com/elliptic-curve-cryptography
      @key_pair = OpenSSL::PKey::EC.generate("secp256k1")
      @public_key = @key_pair.public_key.to_bn.to_s(16).downcase
    end
  
    # 新しい取引を作成する
    # recipient（受信者）は送り先のアドレス
    def create_transaction(recipient:, amount:)
      raise ArgumentError unless recipient.is_a?(String) && amount.is_a?(Integer)

      if amount > balance
        p '残高不足です。'
        return
      end
      Blockchain::Transaction.create_transaction(sender_wallet: self, recipient: recipient, amount: amount)
    end

    # 残高を取得する
    # ブロックチェーンでは、過去のトランザクション履歴を見て、毎回現在の取引残高を算出する。
    def balance
      transactions = @blockchain.all_transactions

      inputs = transactions.reduce(0) do |a, tx|
        tx.input && tx.input.address == @public_key ? a + tx.input.amount : a
      end

      outputs = transactions.reduce(0) do |a, tx|
        a + (tx.outputs || []).reduce(0) do |a2, o|
          o.address == @public_key ? a2 + o.amount : a2
        end
      end

      outputs - inputs
    end
  
    # 署名する
    def sign(data)
      raise ArgumentError unless data.is_a?(String)

      @key_pair.dsa_sign_asn1(data)
    end
  end
end

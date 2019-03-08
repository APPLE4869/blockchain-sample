Dir.glob('./src/**/*.rb').each { |file| require file }

# マイニング中のブロックのハッシュを見る場合は、スクリプト実行時に引数として 1 を渡す。
LOOKING_BLOCK_HASH_DURING_MINING = ARGV[0] == "1"

p "/-----********** Start Miningスクリプト **********-----/"

p "Event ブロックチェーンの誕生"
blockchain = Blockchain::Base.new
# ネットワークを扱うrouterオブジェクトを生成しておく。
router = Router::Base.new(blockchain: blockchain)

sleep(1)

p "Event アカウント（ウォレット）を作成（マイニングの成功報酬を受け取るためのもの）"
wallet = Wallet::Base.new(blockchain: blockchain, router: router)
p "  自分のアドレス : #{wallet.public_key}"
p "  残高 : #{wallet.balance}"

sleep(1)

def mining(blockchain, wallet, router)
  p "Event マイニング開始..."
  miner = Miner::Base.new(blockchain: blockchain, reward_address: wallet.public_key, router: router)
  miner.mine(output: LOOKING_BLOCK_HASH_DURING_MINING)
  p "Event マイニング終了"
  p "  ハッシュ値 : #{blockchain.last_hash}"

  sleep(1)

  p "Event ウォレットの残高を確認（マイニング報酬を獲得している。）"
  p "  残高 : #{wallet.balance}"
end

loop do
  mining(blockchain, wallet, router)

  p "続けてマイニングを行いますか？ y or else"
  input = gets.strip
  break if input != "y"
end

p "*** 最終的なブロックチェーンのデータ ***"
p blockchain.blocks.map(&:to_h)

p "/-----********** Finish Miningスクリプト **********-----/"

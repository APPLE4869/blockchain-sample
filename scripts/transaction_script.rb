Dir.glob('./src/**/*.rb').each { |file| require file }

p "/-----********** Start Transactionスクリプト **********-----/"

p "EVENT ブロックチェーンの誕生"
blockchain = Blockchain::Base.new
# ネットワークを扱うrouterオブジェクトを生成しておく。
router = Router::Base.new(blockchain: blockchain)

# 前準備
p "Aさん、Bさん、Cさんのアカウント（ウォレット）を準備中..."
## Aさん、Bさん、Cさんそれぞれのウォレットを作成
a_wallet = Wallet::Base.new(blockchain: blockchain, router: router)
b_wallet = Wallet::Base.new(blockchain: blockchain, router: router)
c_wallet = Wallet::Base.new(blockchain: blockchain, router: router)

## Aさん、Bさん、Cさんの宛て先を定義
a_recipient = a_wallet.public_key
b_recipient = b_wallet.public_key
c_recipient = c_wallet.public_key

## Aさん、Bさん、Cさんそれぞれのマイニング用オブジェクトを生成
a_miner = Miner::Base.new(blockchain: blockchain, reward_address: a_wallet.public_key, router: router)
b_miner = Miner::Base.new(blockchain: blockchain, reward_address: b_wallet.public_key, router: router)
c_miner = Miner::Base.new(blockchain: blockchain, reward_address: c_wallet.public_key, router: router)

## この後の取引用にAさん、Bさんにコインを付与しておく。（事前にマイニングをして報酬のコインを入手してもらう）
a_miner.mine
a_miner.mine
b_miner.mine

# 取引処理
def tract(wallet:, recipient:, amount:)
  wallet.create_transaction(recipient: recipient, amount: amount)
end

# 残高を表示
def print_balances(a_wallet, b_wallet, c_wallet)
  p "---------- 現時点での残高 ----------"
  p " Aさんの残高 : #{a_wallet.balance}"
  p " Bさんの残高 : #{b_wallet.balance}"
  p " Cさんの残高 : #{c_wallet.balance}"
  p "---------- 現時点での残高 ----------"
end

puts
p "取引のシュミレーションを開始します。"
puts

print_balances(a_wallet, b_wallet, c_wallet)

loop do
  begin
    p "誰のウォレットを使いますか？ A or B or C"

    person = gets.strip.upcase
    raise "入力内容が不正のため、シュミレーションを終了しました。" unless ["A", "B", "C"].include?(person)
    p "では、#{person}さんのウォレットを使用します。"
    p 

    wallet = 
      case person
      when "A" then
        a_wallet
      when "B" then
        b_wallet
      when "C" then
        c_wallet
      end

    p "Aさんのアドレス ↓"
    p a_recipient
    p "Bさんのアドレス ↓"
    p b_recipient
    p "Cさんのアドレス ↓"
    p c_recipient
    puts
    p "送金相手のアドレスを入力してください。"

    recipient = gets.strip
    p "では、#{recipient}を送金相手に指定します。"

    p "送金するコイン数を入力してください。"
    amount = gets.to_i
    p "---------- 入力情報 ----------"
    p " 利用するウォレットの持ち主 : #{person}さん"
    p " 送金相手のアドレス : #{recipient}"
    p " 送金コイン : #{amount}"
    p "---------- 入力情報 ----------"
    puts
    p "ここまで、入力いただいた情報は上記の通りです。取引を実行してもよろしいですか？ y or else"
    input = gets.strip

    raise "シュミレーションを終了しました。" if input != "y"

    tract(wallet: wallet, recipient: a_recipient, amount: amount)

    p "取引を実行しました。ブロックが生成され次第、取引内容は確定します。"
    p "（この段階（マイニング完了前）では、取引が未確定なので残高に変更はありません。）"
    puts
    
    print_balances(a_wallet, b_wallet, c_wallet)

    puts
    p "誰にマイニングをしてもらいますか？ A or B or C"
    p "（マイニングに成功した人には #{MINING_REWARD} コインが与えられます。）"

    person = gets.strip.upcase
    raise "入力内容が不正のため、シュミレーションを終了しました。" unless ["A", "B", "C"].include?(person)
    p "では、#{person}さんにマイニングをしてもらいます。"
    miner = 
      case person
      when "A" then
        a_miner
      when "B" then
        b_miner
      when "C" then
        c_miner
      end

    p "マイニング開始..."
    miner.mine
    p "マイニング終了"
    puts
    print_balances(a_wallet, b_wallet, c_wallet)

    puts
    p "ここまでで一通りの取引の発生から完了までのシュミレーションが完了しました。"
    p "取引シュミレーションを続けますか？ y or else"
    input = gets.strip

    break if input != "y"

    puts
    p "では、取引シュミレーションを続けます🙇‍"
    puts
  rescue => e
    p e.message
    break
  end
end

p "/-----********** Finish Transactionスクリプト **********-----/"

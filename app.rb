require 'sinatra'
require "json"

Dir.glob('./src/**/*.rb').each { |file| require file }

blockchain = Blockchain::Blockchain.new
wallet = Wallet::Base.new(blockchain)
miner = Miner::Base.new(blockchain: blockchain, reward_address: wallet.public_key)

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/blocks' do
  blockchain.blocks.reverse.to_json
end

get '/transactions' do
  miner.transaction_pool.to_json
end

post '/transact' do
  wallet.create_transaction(recipient: params["recipient"], amount: params["amount"].to_i)
  redirect '/transactions'
end

get '/wallet' do
  { address: wallet.public_key, blance: wallet.balance }.to_json
end

post '/mine' do
  miner.mine
  redirect '/blocks'
end

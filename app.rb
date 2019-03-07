# coding: utf-8

require 'sinatra'
require "json"

Dir.glob('./src/**/*.rb').each { |file| require file }

blockchain = Blockchain::Base.new
router = Router::Base.new(blockchain: blockchain)
wallet = Wallet::Base.new(blockchain: blockchain, router: router)
miner = Miner::Base.new(blockchain: blockchain, reward_address: wallet.public_key, router: router)

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/blocks' do
  blockchain.blocks.map.with_index do |block, i|
    block.to_h.merge(hash: block.hash, height: i)
  end.reverse.to_json
end

get '/transactions' do
  miner.transaction_pool.map(&:to_h).to_json
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

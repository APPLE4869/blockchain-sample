Dir.glob('./src/**/*.rb').each { |file| require file }

block_chain = Blockchain::Blockchain.new
wallet = Wallet::Base.new(block_chain)
miner = Miner::Base.new(block_chain, wallet.public_key)

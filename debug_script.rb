# Dir.glob('./src/**/*.rb').each { |file| require file }

#require 'eventmachine'
#require 'em-http-request'
require 'em-websocket'

# block_chain = Blockchain::Blockchain.new
# wallet = Wallet::Base.new(block_chain)
# miner = Miner::Base.new(block_chain, wallet.public_key)

EM::WebSocket.start(host: "0.0.0.0", port: 7080) do |ws|
  p "--------------------------------"
  ws.onopen do |handshake|
    puts "WebSocket connection open"

    ws.send("Hello Client, you connected to #{handshake.path}")
  end

  ws.onmessage do |data|
    puts "Recieved message: #{data}"
    ws.send "Pong: #{data}"
    # ここでケース文を実行
  end

  ws.onclose do
    puts "Connection closed"
  end
end


# EventMachine.run do
#   # @see https://www.igvita.com/2009/12/22/ruby-websockets-tcp-for-the-browser/
#   http = EventMachine::HttpRequest.new("ws://yourservice.com/websocket").get :timeout => 0

#   http.errback { puts "oops" }
#   http.callback {
#     puts "WebSocket connected!"
#     http.send("Hello client")
#   }

#   http.stream { |msg|
#     puts "Recieved: #{msg}"
#     http.send "Pong: #{msg}"
#   }
# end

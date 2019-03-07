# coding: utf-8
require 'em-websocket'

class P2pServer
  def initialize(blockchain:, message_handler:, p2p_enabled:)
    raise ArgumentError unless blockchain.is_a?(Blockchain::Base) && (p2p_enabled == true || p2p_enabled == false)

    @sockets = []
    @blockchain = blockchain
    @message_handler = message_handler

    listen if p2p_enabled
  end

  def listen
    EventMachine::WebSocket.start(host: "0.0.0.0", port: P2P_PORT) do |socket|
      socket.onopen { connect_to_socket(socket) }
    end

    connect_to_peers
    p "P2P Listening on #{P2P_PORT}"
  rescue => e
    p e.message
    p 'P2Pサーバの起動に失敗しました。'
  end

  def connect_to_peers
    PEERS.each do |peer|
      EventMachine::WebSocket.start(peer) do |socket|
        socket.onopen { connect_to_socket(socket) }
      end
    end
  end

  def connect_to_socket(socket)
    raise ArgumentError unless socket.is_a?(WebSocket)
    @sockets << socket

    p 'Socket connected'
    socket.onmessage do |data|
      p "received from peer: #{data}"
      data = JSON.parse(data)
      @message_handler.message_handler(data)
    end

    send_blockchain(socket)
  end

  def send_blockchain(socket)
    raise ArgumentError unless socket.is_a?(WebSocket)

    P2pServer.send_data(
      socket: socket,
      data: { type: MessageType::BLOCK_CHAIN, payload: @blockchain.blocks.map(&:to_json) }
    )
  end

  def broadcast_transaction(transaction)
    raise ArgumentError unless transaction.is_a?(Blockchain::Transaction)

    @sockets.each do |socket|
      P2pServer.send_data(
        socket: socket,
        data: { type: MessageType::TRANSACTION, payload: transaction.to_json }
      )
    end
  end

  def broadcast_mined
    @sockets.each do |socket|
      P2pServer.send_data(
        socket: socket,
        data: { type: MessageType::MINED, payload: @blockchain.blocks.map(&:to_json) }
      )
    end
  end

  def self.send_data(socket:, data:)
    raise ArgumentError unless socket.is_a?(WebSocket)

    p "--------------send_data-------------"
    p data.to_json
    socket.send(data.to_json)
  end
end

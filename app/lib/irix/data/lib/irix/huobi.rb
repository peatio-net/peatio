# frozen_string_literal: true

module Irix
  class Huobi < Peatio::Upstream::Base
    require 'time'

    MIN_INCREMENT_COUNT_TO_SNAPSHOT = 100
    MIN_PERIOD_TO_SNAPSHOT = 5
    MAX_PERIOD_TO_SNAPSHOT = 60

    attr_accessor :snap, :snapshot_time, :increment_count, :sequence_number,
                  :asks, :bids
    # WS huobi global
    # websocket: "wss://api.huobi.pro/ws/"
    # WS for krw markets
    # websocket: "wss://api-cloud.huobi.co.kr/ws/"

    def initialize(config)
      super
      @connection = Faraday.new(url: (config['rest']).to_s) do |builder|
        builder.response :json
        builder.response :logger if config['debug']
        builder.adapter(@adapter)
        unless config['verify_ssl'].nil?
          builder.ssl[:verify] = config['verify_ssl']
        end
      end
      @ping_set = false
      @rest = (config['rest']).to_s
      @ws_url = (config['websocket']).to_s
    end

    def ws_read_message(msg)
      data = Zlib::GzipReader.new(StringIO.new(msg.data.map(&:chr).join)).read
      Rails.logger.debug { "received websocket message: #{data}" }

      object = JSON.parse(data)
      ws_read_public_message(object)
    end

    def ws_read_public_message(msg)
      if msg['ping'].present?
        @ws.send(JSON.dump('pong': msg['ping']))
        return
      end

      case msg['ch']
      when /market\.#{@target}\.trade\.detail/
        detect_trade(msg.dig('tick', 'data'))
      when /market\.#{@target}\.mbp\.150/
        detect_order(msg.dig('tick'))
      end
    end

    def detect_order(msg)
      if @increment_count < MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time <= Time.now - MAX_PERIOD_TO_SNAPSHOT
        publish_snapshot
        @increment_count = 0
      elsif @increment_count >= MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time < Time.now - MIN_PERIOD_TO_SNAPSHOT
        publish_snapshot
        @increment_count = 0
      end
      fill_increment(msg)
    end

    def fill_increment(inc)
      fill_side(inc, "bids")
      fill_side(inc, "asks")
      @increment_count += 1
    end

    def fill_side(inc, side)
      inc[side].each do |price_point|
        price = price_point[0]
        amount = price_point[1]
        if amount.zero?
          @snap[side].delete_if { |point| point[0] == price.to_s }
        else
          @snap[side].delete_if { |point| point[0] == price.to_s }
          @snap[side] << [price.to_s, amount.to_s]
        end
        if side == "bids"
          @bids.delete_if { |point| point[0] == price }
          @bids << [price.to_s, amount.to_s]
        elsif side == "asks"
          @asks.delete_if { |point| point[0] == price }
          @asks << [price.to_s, amount.to_s]
        end
      end
    end

    def publish_increment
      inc = {}
      inc['bids'] = @bids.sort.reverse if @bids.present?
      inc['asks'] = @asks.sort if @asks.present?
      if inc.present?
        @sequence_number += 1
        @peatio_mq.enqueue_event('public', @market, 'ob-inc',
                                 'bids' => inc['bids'], 'asks' => inc['asks'],
                                 'sequence' => @sequence_number)
      end
      @bids = []
      @asks = []
    end

    def publish_snapshot
      @snapshot_time = Time.now
      @peatio_mq.enqueue_event('public', @market, 'ob-snap',
                               'bids' => @snap['bids'].sort.reverse,
                               'asks' => @snap['asks'].sort,
                               'sequence' => @sequence_number)
    end

    def detect_trade(msg)
      msg.map do |t|
        trade =
          {
            'tid' => t['tradeId'],
            'amount' => t['amount'].to_d,
            'price' => t['price'].to_d,
            'date' => t['ts'] / 1000,
            'taker_type' => t['direction']
          }
        notify_public_trade(trade)
      end
    end

    def ws_connect
      super
      return if @ping_set

      Fiber.new do
        EM::Synchrony.add_periodic_timer(80) do
          @ws.send(JSON.dump('ping' => Time.now.to_i))
        end
      end.resume
      @ping_set = true
    end

    def subscribe_trades(market, ws)
      return unless @config['trade_proxy']

      sub = {
        'sub' => "market.#{market}.trade.detail"
      }

      Rails.logger.info 'Open event' + sub.to_s
      EM.next_tick do
        ws.send(JSON.generate(sub))
      end
    end

    def subscribe_orderbook(market, ws)
      return unless @config['orderbook_proxy']

      @sequence_number = 0
      @increment_count = 0
      @snapshot_time = Time.now
      @bids = []
      @asks = []
      @snap = { 'asks' => [], 'bids' => [] }
      sub = {
        'sub' => "market.#{market}.mbp.150"
      }

      Rails.logger.info 'Open event' + sub.to_s
      EM.next_tick do
        ws.send(JSON.generate(sub))
      end
      Fiber.new do
        EM::Synchrony.add_periodic_timer(0.2) do
          publish_increment
        end
      end.resume
    end
  end
end

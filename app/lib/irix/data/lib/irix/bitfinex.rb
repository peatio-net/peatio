# frozen_string_literal: true

module Irix
  class Bitfinex < Peatio::Upstream::Base
    require 'time'

    MIN_INCREMENT_COUNT_TO_SNAPSHOT = 100
    MIN_PERIOD_TO_SNAPSHOT = 5
    MAX_PERIOD_TO_SNAPSHOT = 60

    attr_accessor :snap, :snapshot_time, :increment_count, :sequence_number,
                  :open_channels, :asks, :bids

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
      @open_channels = {}
      @ping_set = false
      @rest = (config['rest']).to_s
      @ws_url = (config['websocket']).to_s
    end

    def ws_connect
      super
      return if @ping_set

      @ws.on(:open) do |_e|
        subscribe_trades(@target, @ws)
        subscribe_orderbook(@target, @ws)
        logger.info { 'Websocket connected' }
      end

      Fiber.new do
        EM::Synchrony.add_periodic_timer(80) do
          @ws.send('{"event":"ping"}')
        end
      end.resume
      @ping_set = true
    end

    def subscribe_trades(market, ws)
      return unless @config['trade_proxy']

      sub = {
        event: 'subscribe',
        channel: 'trades',
        symbol: market.upcase
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
      @bids = []
      @asks = []
      @snap = { 'asks' => [], 'bids' => [] }
      sub = {
        event: 'subscribe',
        channel: 'book',
        symbol: market.upcase,
        len: 25
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

    def ws_read_public_message(msg)
      if msg.is_a?(Array)
        if msg[1] == 'hb'
          @ws.send('{"event":"ping"}')
        elsif @open_channels[msg[0]] == 'trades'
          detect_trade(msg)
        elsif @open_channels[msg[0]] == 'book'
          detect_order(msg)
        end
      elsif msg.is_a?(Hash)
        message_event(msg)
      end
    end

    def detect_trade(msg)
      if msg[1] == 'tu'
        data = msg[2]
        trade =
          {
            'tid' => data[0],
            'amount' => data[2].to_d.abs,
            'price' => data[3],
            'date' => data[1] / 1000,
            'taker_type' => data[2].to_d.positive? ? 'buy' : 'sell'
          }
        notify_public_trade(trade)
      end
    end

    # [
    #   CHANNEL_ID,
    #   [
    #     PRICE,
    #     COUNT,
    #     AMOUNT
    #   ]
    # ]
    def detect_order(msg)
      if msg[1][0].is_a?(Array)
        msg[1].each do |point|
          if point[2] > 0
            @snap['bids'] << [point[0].to_s, point[2].to_s]
          else
            @snap['asks'] << [point[0].to_s, point[2].abs.to_s]
          end
        end
        publish_snapshot
      else
        if @increment_count < MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time <= Time.now - MAX_PERIOD_TO_SNAPSHOT
          publish_snapshot
          @increment_count = 0
        elsif @increment_count >= MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time < Time.now - MIN_PERIOD_TO_SNAPSHOT
          publish_snapshot
          @increment_count = 0
        end

        fill_increment(msg[1])
      end
    end

    def fill_increment(order)
      side = order[2].positive? ? 'bid' : 'ask'
      price = order[0].to_s
      if order[1].zero?
        amount = 0
        @snap["#{side}s"].delete_if { |point| point[0] == price }
      else
        amount = order[2].abs.to_s
        @snap["#{side}s"].delete_if { |point| point[0] == price }
        @snap["#{side}s"] << [price.to_s, amount.to_s]
      end
      if side == 'bid'
        @bids.delete_if { |point| point[0] == price }
        @bids << [price.to_s, amount.to_s]
      elsif side == 'ask'
        @asks.delete_if { |point| point[0] == price }
        @asks << [price.to_s, amount.to_s]
      end
      @increment_count += 1
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

    def message_event(msg)
      case msg['event']
      when 'subscribed'
        Rails.logger.info "Event: #{msg}"
        @open_channels[msg['chanId']] = msg['channel']
      when 'error'
        Rails.logger.info "Event: #{msg} ignored"
      end
    end

    def info(msg)
      Rails.logger.info "Bitfinex: #{msg}"
    end
  end
end

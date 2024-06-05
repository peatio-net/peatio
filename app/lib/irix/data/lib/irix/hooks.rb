# frozen_string_literal: true

module Irix
  module Hooks
    class << self
      def register
        Peatio::Upstream.registry[:bitfinex] = Irix::Bitfinex
        Peatio::Upstream.registry[:huobi] = Irix::Huobi
      end
    end

    if defined?(Rails::Railtie)
      require 'irix/railtie'
    else
      register
    end
  end
end

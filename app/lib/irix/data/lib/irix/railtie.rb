# frozen_string_literal: true

module Irix
  class Railtie < Rails::Railtie
    config.after_initialize do
      Hooks.register
    end
  end
end

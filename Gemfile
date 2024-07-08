# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 2.7.8'

gem 'ransack', '~> 2.5.0'
gem 'rails', '~> 6.1.0'
gem 'puma', '~> 4.3.8'
gem 'mysql2', '~> 0.5.6'
gem 'redis', '~> 4.1.2', require: ['redis', 'redis/connection/hiredis']
gem 'hiredis', '~> 0.6.0'
gem 'figaro', '~> 1.2.0'
gem 'hashie', '~> 3.6.0'
gem 'aasm', '~> 5.0.8'
gem 'bunny', '~> 2.14.4'
gem 'cancancan', '~> 3.1.0'
gem 'enumerize', '~> 2.8.1'
gem 'kaminari', '~> 1.2.1'
gem 'rbtree', '~> 0.4.2'
gem 'grape', '~> 1.3.1'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger', '~> 0.30.1'
gem 'grape-swagger-ui', '~> 2.2.8'
gem 'grape-swagger-entity', '~> 0.2.5'
gem 'grape_logging', '~> 1.8.0'
gem 'rack-attack', '~> 5.4.2'

gem 'faraday', '~> 1.10'
gem 'better-faraday', '~> 2.0', '>= 2.0.1'
gem 'faraday_middleware', '~> 1.2'
gem 'faye', '~> 1.4'
gem 'eventmachine', '~> 1.2'
gem 'em-synchrony', '~> 1.0'
gem 'jwt', '~> 2.2.0'
gem 'email_validator', '~> 2.2.4'
gem 'validate_url', '~> 1.0.4'
gem 'god', '~> 0.13.7', require: false
gem 'arel_extensions', '~> 2.1'
gem 'sentry-raven', '~> 3.1', require: false
gem 'memoist', '~> 0.16.0'
gem 'method-not-implemented', '~> 1.0.1'
gem 'validates_lengths_from_database', '~> 0.7.0'
gem 'jwt-multisig', '~> 1.0.0'
gem 'cash-addr', '~> 0.2.0', require: 'cash_addr'
gem 'digest-sha3', '~> 1.1.0'
gem 'scout_apm', '~> 2.4', require: false
gem 'peatio', '~> 3.1', '>= 3.1.1'
gem 'peatio-bitcoincash', '~> 3.1'
gem 'peatio-bitgo', '~> 3.1'
gem 'peatio-dash', '~> 3.1'
gem 'peatio-electrum', '~> 3.1'
gem 'peatio-litecoin', '~> 3.1'
gem 'peatio-ripple', '~> 3.1'

gem 'rack-cors', '~> 1.0.6', require: false
gem 'jwt-rack', '~> 0.1.0', require: false
gem 'env-tweaks', '~> 1.0.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'net-http-persistent', '~> 4.0.1'
gem 'influxdb', '~> 0.7.0'
gem 'safe_yaml', '~> 1.0.5', require: 'safe_yaml/load'
gem 'composite_primary_keys', '~> 13.0.8'
gem 'vault', '~> 0.12', require: false
# gem 'psych', '~> 5.1', '>= 5.1.2'
gem 'irix3', '~> 3.2.1.1'

group :development, :test do
  # gem 'irb'
  gem 'bump',         '~> 0.7'
  gem 'faker',        '~> 1.8'
  gem 'pry-byebug',   '~> 3.7'
  gem 'bullet'
  gem 'grape_on_rails_routes'
end

group :development do
  gem 'annotate',   '~> 3.1.0'
  gem 'ruby-prof',  '~> 0.17.0', require: false
  gem 'listen', '~> 3.1.5'
  gem 'rb-inotify', '~> 0.10.0'
  gem 'ffi', '~> 1.14.1'

end

group :test do
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'rspec-retry',         '~> 0.6'
  gem 'webmock',             '~> 3.5'
  gem 'database_cleaner',    '~> 1.7'
  gem 'mocha',               '~> 1.8', require: false
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  gem 'timecop',             '~> 0.9'
  gem 'rubocop-rspec',       '~> 1.32', require: false
end

# Load gems from Gemfile.plugin.
# Dir.glob File.expand_path('../Gemfile.plugin', __FILE__) do |file|
#   eval_gemfile file
# end

gem "pg", "~> 1.2"

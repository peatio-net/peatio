require 'net/http'
require 'json'
require 'uri'

class EthereumAccountService
  CLEF_ENDPOINT = ENV.fetch('CLEF_RPC_URL', ENV['CLEF_RPC_ADDR'])

  def self.create_address
    uri = URI.parse(CLEF_ENDPOINT)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      id: 0,
      jsonrpc: '2.0',
      method: 'account_new',
      params: []
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    parsed = JSON.parse(response.body)
    if parsed['result']
      Rails.logger.info { "[Clef] Created new ETH address: #{parsed['result']}" }
      parsed['result']
    else
      Rails.logger.error { "[Clef] Failed to create account: #{parsed['error'] || response.body}" }
      nil
    end
  rescue => e
    Rails.logger.error { "[Clef] Exception while creating account: #{e.message}" }
    nil
  end
end

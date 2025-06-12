require 'faraday'
require 'json'

class EthService
  DEFAULT_API_URL = ENV.fetch('CLEF_RPC_URL', ENV['ETH_TOOL_API_URL'])

  def initialize
    @conn = Faraday.new(url: DEFAULT_API_URL) do |f|
      f.request :json
      f.response :json, content_type: 'application/json'
    end
  end

  def create_account(password)
    response = @conn.post('/create_account', { password: password })
    raise response.body['error'] unless response.success?

    response.body['address']
  end

  def send_transaction(from_address:, password:, to:, amount:)
    response = @conn.post('/send_transaction', {
                            address: from_address,
                            password: password,
                            to: to,
                            value: amount
                          })
    raise response.body['error'] unless response.success?

    response.body['txHash']
  end
end

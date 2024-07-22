module Faraday
  class Response
    def assert_success!
      unless success?
        raise "HTTP Request failed with status code #{status}"
      end
    end

    def success?
      status >= 200 && status < 300
    end
  end
end

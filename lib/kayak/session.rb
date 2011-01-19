# Represents the Kayak API.
# Check http://www.kayak.com/labs/api/search/spec.html for more info
module Kayak
  class Session
    attr_reader :session_id

    def initialize(token)
      @token = token

      session_results = Kayak::Api.new_session(@token)
      error           = session_results[:error]
      @session_id     = session_results[:session_id]

      validate_response(@session_id, error)
    end

    def search_flights(from, to, whn)
      Search.new(self, Kayak::Api.search(@session_id, from, to, whn))
    end

    private

    def validate_response(response, error)
      unless response
        raise InvalidSessionError, error
      end
    end
  end
end

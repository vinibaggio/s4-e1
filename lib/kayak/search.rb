module Kayak
  # Represents a Kayak search. Must be polled for results.
  class Search
    def initialize(kayak_session, searchid)
      @session = kayak_session
      @search_id = searchid
    end
  end
end

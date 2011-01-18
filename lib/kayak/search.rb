module Kayak
  # Represents a Kayak search. Must be polled for results.
  class Search
    include HTTParty
    SEARCH_QTY = 10

    attr_reader :result_count, :results

    def initialize(kayak_session, searchid)
      @session = kayak_session
      @search_id = searchid
      @result_count = 0
      @results = []
      @state = :init
    end

    def fetch
      if not complete?
        search_qty = @result_count > 0 ? @result_count : SEARCH_QTY
        query = {
          :searchid => @search_id,
          :c        => search_qty,
          :m        => 'normal',
          :d        => 'up',
          :s        => 'price',
          :_sid_    => @session.session_id,
          :version  => '1',
          :apimode  => '1'
        }

        response = self.class.get(search_url, :query => query)
        parse_search_results(response.parsed_response['searchresult'])
      else
        @results
      end
    end

    def init?
      @state == :init
    end

    def fetching?
      @state == :fetching
    end

    def complete?
      @state == :complete
    end

    private
    def parse_search_results(results)
      more_pending = results['morepending'] == 'true'
      @result_count = results['count'].to_i

      if more_pending
        fetching(results)
      else
        complete(results)
      end

      @results
    end

    def fetching(results)
      @state = :fetching
      read_trips(results)
    end

    def complete(results)
      read_trips(results)
      @state = :complete
    end

    def search_url
      Kayak::BASE_URL + '/s/apibasic/flight'
    end

    def read_trips(results)
      @results = Kayak::Trip.parse(results['trips'])
    end
  end
end

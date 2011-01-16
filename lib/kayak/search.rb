module Kayak
  # Represents a Kayak search. Must be polled for results.
  class Search
    include HTTParty
    attr_reader :result_count, :results

    def initialize(kayak_session, searchid)
      @session = kayak_session
      @search_id = searchid
      @result_count = 0
      @results = []
      @state = :init
    end

    def fetch
      query = {
        :searchid => @search_id,
        :c => 10,
        :m => 'normal',
        :d => 'up',
        :s => 'price',
        :_sid_ => @session.session_id,
        :version => '1',
        :apimode => '1'
      }

      response = self.class.get(search_url, :query => query)
      p response
      p response.body

      parse_search_results(response.parsed_response['searchresults'])
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

    protected
    def parse_search_results(results)
      more_pending = results['more_pending'] == 'true'
      @result_count += results['count'].to_i

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
      @state = :complete
      # tell Kayak we're done
      query = {
        :searchid => @search_id,
        :c => @result_count,
        :m => 'normal',
        :d => 'down',
        :s => 'price',
        :_sid_ => @session.session_id,
        :version => '1',
        :apimode => '1'
      }
      self.class.get(search_url, :query => query)
    end

    def search_url
      Kayak.base_url + '/s/apibasic/flight'
    end

    def read_trips(results)
      results << Kayak::Trip.parse(results['trips'])
    end
  end
end

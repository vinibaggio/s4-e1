module Kayak
  class Format
    class << self
      def parse_time(time_as_string)
        # Supplied by Chronic
        Time.strptime(time_as_string, "%Y/%m/%d %H:%M")
      end

      def date_string(date)
        date.strftime("%m/%d/%Y")
      end

      def time_string(time)
        time.strftime("%Y/%m/%d %H:%M")
      end
    end
  end
end

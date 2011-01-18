module Kayak
  class Data
    class << self
      def airport_name(airport_code)
        # airport_data = ["La Guardia", "US"]
        airport_data = lookup_for(airport_code, 'airports.csv')

        # La Guardia (LGA), US
        "#{airport_data[0]} (#{airport_code}), #{airport_data[1]}"
      end

      def airline_name(airline_code)
        # ["Continental"]
        lookup_for(airline_code, 'airlines.csv')[0]
      end

      private
      def data_file_path(filename)
        File.expand_path(File.dirname(__FILE__) + '/../../data/' + filename)
      end

      def lookup_for(item_code, filename)
        result = nil
        file = File.open(data_file_path(filename)) do |file|
          file.each_line do |line|
            code, *data = line.chomp.split(',')
            if code == item_code
              result = data
              break
            end
          end
        end
        result
      end
    end
  end
end

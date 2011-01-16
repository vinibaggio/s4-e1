require 'optparse'
require 'yaml'

module Kayak
  class CLI
    def initialize(args)
      @options = {
        :when => Date.today,
        :from => '',
        :to => '',
        :token => try_to_load_from_yaml('kayak.yml')
      }

      opt = OptionParser.new do |opts|
        opts.banner = "kayak is a program to search flights in kayak.com.\nUsage: [options]"

        opts.on('-f', '--from AIRPORT', 'From which airport (3 letter code, e.g. LAX)') do |from|
          @options[:from] = from
        end

        opts.on('-t', '--to AIRPORT', 'To which airport (3 letter code, e.g. SFO)') do |to|
          @options[:to] = to
        end

        time_help = ["Date when you want the flight. There is support for some",
                    "natural language, examples:",
                    "'tomorrow', 'May 1st', 'monday', 'next sunday'"]

        opts.on('-w', '--when DATE', *time_help) do |whn|
          @options[:when] = Chronic.parse(whn)
        end

        opts.on('--token TOKEN', 'Specify developer token, if not using kayak.yml') do |token|
          @options[:token] = token
        end

      end
      opt.parse!

      valid, message = validate_options

      if not valid
        puts "ERROR: " + message
        puts opt
        exit
      end
    end

    def validate_options
      if @options[:from].blank? || @options[:to].blank?
        [false, "Missing either --from or --to, please supply both."]
      elsif @options[:when].nil?
        [false, "Date is not valid."]
      elsif @options[:token].blank?
        [false, "Token is not present."]
      else
        [true, '']
      end
    end

    def run
      kayak_session = Kayak::Session.new(@options[:token])
      kayak_search = kayak_session.search_flights(@options[:from],
                                                  @options[:to],
                                                  @options[:when])

      trips = kayak_search.fetch
      while !kayak_search.complete? or kayak_search.result_count < 10
        sleep 1
        trips = kayak_search.fetch
      end

      print_trips(trips)
    end

    protected

    def print_trips(trips)
      trips.each do |trip|
        print "Price: USD #{trip.price}"
        print "\t\t\t"
        trip.flights.each do |flight|
          print "Airline: #{flight.airline}\n"
          print "\t\t\t\tOrigin: #{flight.origin}\n"
          print "\t\t\t\tDestination: #{flight.destination}\n"
          print "\t\t\t\tCabin: #{flight.cabin}\n"
          print "\t\t\t\tDuration: %.1f hours\n" % (flight.duration_minutes/60)
          print "\t\t\t\tStops: #{flight.stops}\n"
          print "\t\t\t\tDeparture: #{format_time(flight.departure_time)}\n"
          print "\t\t\t\tArrival: #{format_time(flight.arrival_time)}\n"
          if flight.segments.count > 0
            puts
            print "\tStops:\n"
            flight.segments.each do |segment|
              print "\t#{segment.origin} to #{segment.destination}"
              print " @ #{format_time(segment.departure_time)}"
              print", arrives #{format_time(segment.arrival_time)}\n"
            end
          end
        end
        puts
      end
    end

    def format_time(time)
      time.strftime("%Y/%m/%d %H:%M")
    end

    def try_to_load_from_yaml(yaml_file)
      if File.exists?(yaml_file)
        yaml = YAML.load(open(yaml_file))
        if yaml['kayak'] # if it is present, return the value, else nil will do
          yaml['kayak']['key']
        end
      end
    end
  end
end

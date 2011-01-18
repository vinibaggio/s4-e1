require 'rubygems'
require 'bundler/setup'
Bundler.require

module Kayak
  InvalidSessionError = Class.new(StandardError)

  class << self
    def base_url
      "http://api.kayak.com"
    end

    def parse_time(date_in_string)
      # Supplied by Chronic
      Time.strptime(date_in_string, "%Y/%m/%d %H:%M")
    end
  end
end

require 'kayak/cli'
require 'kayak/data'
require 'kayak/flight'
require 'kayak/trip'
require 'kayak/search'
require 'kayak/session'


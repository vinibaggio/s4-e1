require 'rubygems'
require 'bundler/setup'
Bundler.require

module Kayak
  InvalidSessionError = Class.new(StandardError)
  BASE_URL = "http://api.kayak.com"
end

require 'kayak/format'
require 'kayak/cli'
require 'kayak/data'
require 'kayak/flight'
require 'kayak/trip'
require 'kayak/search'
require 'kayak/session'


require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'kayak/connection'

module Kayak
  InvalidSessionError = Class.new(StandardError)
end

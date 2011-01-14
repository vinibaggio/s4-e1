require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'kayak/session'

module Kayak
  InvalidSessionError = Class.new(StandardError)
end

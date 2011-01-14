require 'rubygems'
require 'bundler/setup'
Bundler.require

module Kayak
  InvalidSessionError = Class.new(StandardError)

  def self.base_url
    "http://api.kayak.com"
  end
end

require 'kayak/search'
require 'kayak/session'


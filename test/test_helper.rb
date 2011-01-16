require 'rubygems'
require 'bundler/setup'
Bundler.require :test

require 'test/unit'

require 'kayak'


def load_fixture(filename)
  File.read(File.expand_path('../fixtures/' + filename, __FILE__))
end

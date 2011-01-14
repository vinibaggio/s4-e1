require 'rubygems'
require 'bundler/setup'
Bundler.require :test

require 'test/unit'

# add lib/kayak to the loadpath
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib/'))

require 'kayak'


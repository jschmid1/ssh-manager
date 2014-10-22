#!/usr/bin/ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require_relative '../lib/ssh/manager/client'
require_relative '../lib/ssh/manager/cli'
require_relative '../lib/ssh/manager/db'

client = SSH::Manager::Client.new(ARGV.dup)
client.execute!
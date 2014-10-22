require_relative 'db'
require 'debugger'

#debugger

@connections = SSH::Manager::Database.new.get_connection_data
@connections.map{|x| "#{x.map {|y| print "#{y} "}}"}

#!/usr/bin/ruby
require "../lib/ssh/manager/client"

SSH::Manager::Client.connect('192.168.178.26', 'jxs')
  #SSH::Manager::Client.list

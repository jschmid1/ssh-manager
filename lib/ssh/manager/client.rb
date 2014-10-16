#require_relative "../manager"
require 'debugger'

module SSH
  module Manager
    class Client

      @list_arr = {1 => ["192.168.0.1", "foo"],
                   2 => ["192.168.0.2", "root"],
                   3 => ["192.168.0.3", "bar"]
                  }

      # List all entries
      def self.list_all(list)
        (1..list.size).each do |x|
          puts "#{x}: #{list[x]}"
        end
      end

      # Connect to specified connection with optional params
      def self.connect(ip, user, param=[] )
        ip.to_i
        #add params
        %x(xfce4-terminal --command="ssh #{user}@#{ip}")
      end
    end
  end
end



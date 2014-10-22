require_relative 'db'

module SSH
  module Manager
    class Cli

      def initialize(opts = {})
        @options = opts
        list_all if @options[:list]
      end

      def connect_to(ip, user, params=[] )
        ip.to_i
        %x(xfce4-terminal --command="ssh #{user}@#{ip}")
      end

      def add_connection(ip, user, hostname, port, note)
        SSH::Manager::Database.new.add_new_connection(ip, user, hostname, port, note)
      end

      def delete(ip, user, hostname, port, note)
        #TODO
      end

      def list_all
        @connections = SSH::Manager::Database.new.get_connection_data
        @connections.map{|x| "#{x.map {|y| print "#{y} "}}"}
      end

    end
  end
end


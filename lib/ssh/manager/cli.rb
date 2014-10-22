require_relative 'db'

module SSH
  module Manager
    class Cli

      def initialize(opts = {})
        @options = opts
      end

      def connect_to(id)
        #rewrite, find ip and settings by ID
        ip = SSH::Manager::Database.new.get_connection_data[id.to_i-1][0]
        user = SSH::Manager::Database.new.get_connection_data[id.to_i-1][1]
        debugger
        %x(xfce4-terminal --command="ssh #{user}@#{ip}")
      end

      def add_connection(ip)
        puts "Username: "
        user =$stdin.gets.chomp
        user = 'root' if user == ''
        puts "Hostname: "
        hostname = $stdin.gets.chomp
        puts "port: "
        port = $stdin.gets.chomp
        port = 22 if port == ''
        puts "Notes: "
        note = $stdin.gets.chomp
        SSH::Manager::Database.new.add_new_connection(ip, user, hostname, port, note)
      end

      def delete(id)
        id = id.to_i - 1
        SSH::Manager::Database.new.delete_connection(SSH::Manager::Database.new.get_connection_data[id][0])
      end

      def list_all
        cnt = 0
        # TODO: add indentation functionality with stringlenght etc..
        puts "ID: IP:        USERNAME:      HOSTNAME:     PORT:    NOTES:"
        SSH::Manager::Database.new.get_connection_data.each do |con|
          cnt +=1
          print "#{cnt}: "
          con.each do |para|
            print "#{para} | "
          end
          puts "\n"
        end
      end

    end
  end
end


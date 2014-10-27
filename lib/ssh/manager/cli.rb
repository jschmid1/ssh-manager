require_relative 'db'
require 'yaml'
FileUtils.cp ("#{File.dirname(__FILE__)}/../../../config/settings.yml"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/settings.yml'))
CONFIG = YAML.load_file("#{File.join(ENV['HOME'])}/.config/sshm/settings.yml")

module SSH
  module Manager
    class Cli

      def initialize(opts = {})
        @options = opts
      end

      def connect_to(id)
        ip = SSH::Manager::Database.new.get_connection_data[id.to_i-1][0]
        user = SSH::Manager::Database.new.get_connection_data[id.to_i-1][1]
        # different terminals different behaviour .. i.e. xterm -C 'ssh...'
        # TODO: add function for different terms

        %x(#{CONFIG['terminal']} --command="ssh #{user}@#{ip}")


      end

      def add_connection(ip)
        puts "Username: "
        user =$stdin.gets.chomp
        user = 'root' if user == ''
        puts "Hostname: "
        hostname = $stdin.gets.chomp
        puts "port: "
        port = $stdin.gets.chomp
        port = "22" if port == ''
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
        connections = Hash[SSH::Manager::Database.new.get_connection_data.collect { |x| [cnt+=1, x]}]
        puts "ID IP                  USERNAME            HOSTNAME            PORT                NOTES"
        connections.each do |x|
          print "#{x[0]}: "
          x[1].each do |a|
            printf "%-20s", a
          end
          puts "\n"
        end

      end

      def update(id)
        puts "Username: "
        user =$stdin.gets.chomp
        user = SSH::Manager::Database.new.get_connection_data[id.to_i][1] if user == ''
        puts "Hostname: "
        hostname = $stdin.gets.chomp
        hostname = SSH::Manager::Database.new.get_connection_data[id.to_i][2] if hostname == ''
        puts "port: "
        port = $stdin.gets.chomp
        port = SSH::Manager::Database.new.get_connection_data[id.to_i][3] if port == ''
        puts "Notes: "
        note = $stdin.gets.chomp
        note = SSH::Manager::Database.new.get_connection_data[id.to_i][4] if note == ''
        SSH::Manager::Database.new.update_connection(SSH::Manager::Database.new.get_connection_data[id.to_i][0], user, hostname, port, note)
      end

      def search_for(term)
        SSH::Manager::Database.new.search_for(term).each do |x|
          puts x.all
        end
        puts "All results for searchterm: #{term}"
      end

    end
  end
end


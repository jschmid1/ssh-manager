require_relative 'db'
require 'yaml'
FileUtils.cp ("#{File.dirname(__FILE__)}/../../../config/settings.yml"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/settings.yml'))
CONFIG = YAML.load_file("#{File.join(ENV['HOME'])}/.config/sshm/settings.yml")
require 'debugger'

module SSH
  module Manager
    class Cli

      def initialize(opts = {})
        @options = opts
      end

      def check_term(ip, user)
        if CONFIG['terminal'] == "xfce4-terminal" || CONFIG['terminal'] == "gnome-terminal"
          if CONFIG['tabbed'] == 'true'
            command = '--tab --command='
          else
            command = '--command='
          end
          #TODO: add title --title='connection name to identify '
          %x(#{CONFIG['terminal']} #{command}"ssh #{user}@#{ip}")
        elsif CONFIG['terminal'] == "xterm" || CONFIG['terminal'] == "urxvt"
          %x(#{CONFIG['terminal']} -e "ssh #{user}@#{ip}")
        else
          puts "We dont support #{CONFIG['terminal']} right now"
          puts 'Check Github for further development or contributing'
        end
      end

      def connect_to(id)
        @ip = SSH::Manager::Database.new.get_connection_data[id.to_i-1][0]
        @user = SSH::Manager::Database.new.get_connection_data[id.to_i-1][1]
        check_term(@ip, @user)
        #TODO: check for options
        #TODO: if db[secure_login] = false => http://linuxcommando.blogspot.de/2008/10/how-to-disable-ssh-host-key-checking.html
      end

      def add_connection(ip)
        puts 'Username: '
        user = $stdin.gets.chomp
        user = 'root' if user == ''
        puts 'Hostname: '
        hostname = $stdin.gets.chomp
        puts 'port: '
        port = $stdin.gets.chomp
        port = '22' if port == ''
        puts 'Notes: '
        note = $stdin.gets.chomp
        puts 'Options: '
        options = $stdin.gets.chomp
        options = '' if options == ''
        puts 'Group: '
        group = $stdin.gets.chomp
        count = 0
        created_at = Time.now.to_s
        last_time = Time.now.to_s
        SSH::Manager::Database.new.add_new_connection(ip, user, hostname, port, note, created_at, options, count, group, last_time)
      end

      def delete(id)
        id = id.to_i - 1
        SSH::Manager::Database.new.delete_connection(SSH::Manager::Database.new.get_connection_data[id][0])
      end

      def list_all
        cnt = 0
        connections = Hash[SSH::Manager::Database.new.get_connection_data.collect { |x| [cnt+=1, x]}]
        puts 'ID IP                  USERNAME            HOSTNAME            PORT                NOTES               GROUP'
        connections.each do |x|
          print "#{x[0]}: "
          x[1].each do |a|
            printf '%-20s', a
          end
          puts "\n"
        end
      end

      def update(id)
        puts 'Entries wont change of left out blank.'
        puts 'Username: '
        user =$stdin.gets.chomp
        user = SSH::Manager::Database.new.get_connection_data[id.to_i][1] if user == ''
        puts 'Hostname: '
        hostname = $stdin.gets.chomp
        hostname = SSH::Manager::Database.new.get_connection_data[id.to_i][2] if hostname == ''
        puts 'port: '
        port = $stdin.gets.chomp
        port = SSH::Manager::Database.new.get_connection_data[id.to_i][3] if port == ''
        puts 'Notes: '
        note = $stdin.gets.chomp
        note = SSH::Manager::Database.new.get_connection_data[id.to_i][4] if note == ''
        SSH::Manager::Database.new.update_connection(SSH::Manager::Database.new.get_connection_data[id.to_i][0], user, hostname, port, note)
      end

      def search_for(term)
        puts 'IP                  USERNAME            HOSTNAME            PORT                NOTES               GROUP'
        SSH::Manager::Database.new.search_for(term).each do |x|
          x.all.each do |cons|
            cons.values.each do |each_con|
              printf '%-20s', each_con
            end
            puts "\n"
          end
        end
        puts "All results for searchterm: #{term}"
      end

      def multiple_connection(term)
        SSH::Manager::Database.new.search_for(term).each do |x|
          x.all.each do |dataset|
            check_term(dataset[:ip], dataset[:user])
            #TODO: Add terminalposition
          end
        end
      end

    end
  end
end

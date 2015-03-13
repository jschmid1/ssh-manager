require_relative 'db'
require 'yaml'
FileUtils.cp ("#{File.dirname(__FILE__)}/../../../config/settings.yml"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/settings.yml'))
CONFIG = YAML.load_file("#{File.join(ENV['HOME'])}/.config/sshm/settings.yml")
require_relative 'version'

module SSH
  module Manager
    class Cli

      DATABASE = SSH::Manager::Database.new

      def initialize(opts = {})
        @options = opts
      end

      def check_term(ip, user, via)
        if CONFIG['terminal'] == "xfce4-terminal" || CONFIG['terminal'] == "gnome-terminal"
          if CONFIG['tabbed'] == 'true'
            command = "--title=#{user}@#{ip} --tab --command="
          else
            command = "--title=#{user}@#{ip} --command="
          end
          #TODO: add title --title='connection name to identify '
          #TODO: bug when no terminal is open => wants to open 2 terms
          #TODO: dnslookup
          if via.nil? or via.empty?
            %x(#{CONFIG['terminal']} #{command}"ssh #{user}@#{ip}")
          else
            %x(#{CONFIG['terminal']} #{command}"ssh -A -t #{via} ssh -A -t #{user}@#{ip}")
          end
        elsif CONFIG['terminal'] == "xterm" || CONFIG['terminal'] == "urxvt"
          %x(#{CONFIG['terminal']} -e "ssh #{user}@#{ip}")
        else
          puts "We dont support #{CONFIG['terminal']} right now"
          puts 'Check Github for further development or contributing'
        end
      end

      def connect_to(id)
        via = DATABASE.get_connection_data[id.to_i-1][-1] =~ /@/
        if via.nil?
          @ip = DATABASE.get_connection_data[id.to_i-1][0]
          @user = DATABASE.get_connection_data[id.to_i-1][1]
          check_term(@ip, @user, via)
        else
          @ip = DATABASE.get_connection_data[id.to_i-1][0]
          @user = DATABASE.get_connection_data[id.to_i-1][1]
          via = DATABASE.get_connection_data[id.to_i-1][-1]
          check_term(@ip, @user, via)
        end
        #TODO: check for options
        #TODO: if db[secure_login] = false => http://linuxcommando.blogspot.de/2008/10/how-to-disable-ssh-host-key-checking.html
      end

      def update_available
        new_version =%x(gem search ssh-manager).split(' ')[1].gsub /\((.*)\)/, '\1'
        old_version = SSH::Manager::VERSION
        if new_version<old_version
          puts "There is a update available #{new_version} was released. -> sudo gem update ssh-manager"
        else
        puts "Version: #{old_version} is up to date."
        end
      end

      def transfer_key(id)
        @ip = DATABASE.get_connection_data[id.to_i-1][0]
        @user = DATABASE.get_connection_data[id.to_i-1][1]
        %x(ssh-copy-id #{@user}@#{@ip})
      end

      def transfer_file(filename, id='', dest_path="/home/#{user}/")
        @ip = DATABASE.get_connection_data[id.to_i-1][0]
        @user = DATABASE.get_connection_data[id.to_i-1][1]
        %x(scp #{filename} #{@user}@#{@ip}:#{dest_path}) if File.file?(filename)
        %x(scp -r #{filename} #{@user}@#{@ip}:#{dest_path}) if File.directory?(filename)
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
        puts 'Connect via(ip): '
        connect_via_ip = $stdin.gets.chomp
        puts 'With Username: '
        connect_via_user = $stdin.gets.chomp
        connect_via = ""
        connect_via= "#{connect_via_user}@#{connect_via_ip}" unless connect_via_user.empty?
        count = 0
        created_at = Time.now.to_s
        last_time = Time.now.to_s
        DATABASE.add_new_connection(ip, user, hostname, port, note, connect_via, created_at, options, count, group, last_time)
      end

      def delete(id)
        id = id.to_i - 1
        DATABASE.delete_connection(DATABASE.get_connection_data[id][0])
      end

      def list_all
        cnt = 0
        connections = Hash[DATABASE.get_connection_data.collect { |x| [cnt+=1, x]}]
        puts 'ID IP             USERNAME       NOTES          GROUP'
        connections.each do |x|
          print "#{x[0]}: "
          x[1].each do |a|
            printf '%-15s', a
          end
          puts "\n"
        end
      end

      def update(id)
        puts 'Entries wont change of left out blank.'
        puts 'Username: '
        user =$stdin.gets.chomp
        user = DATABASE.get_connection_data[id.to_i][1] if user == ''
        puts 'Hostname: '
        hostname = $stdin.gets.chomp
        hostname = DATABASE.get_connection_data[id.to_i][2] if hostname == ''
        puts 'port: '
        port = $stdin.gets.chomp
        port = DATABASE.get_connection_data[id.to_i][3] if port == ''
        puts 'Notes: '
        note = $stdin.gets.chomp
        note = DATABASE.get_connection_data[id.to_i][4] if note == ''
        DATABASE.update_connection(DATABASE.get_connection_data[id.to_i][0], user, hostname, port, note)
      end

      def search_for(term)
        puts 'IP                  USERNAME            HOSTNAME            PORT                NOTES               GROUP'
        DATABASE.search_for(term).each do |x|
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
        DATABASE.search_for(term).each do |x|
          x.all.each do |dataset|
            check_term(dataset[:ip], dataset[:user], dataset[:connect_via])
            #TODO: Add terminalposition
          end
        end
      end

    end
  end
end

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
        @pretty_names = {:id => "ID", #TODO :connect_via
                         :ip => "IP or hostname",
                         :user => "Username",
                         :hostname => "Alias",
                         :port => "Port",
                         :note => "Note",
                         :options => "Options",
                         :group => "Group",
                         :connect_via => "Connect via (id)"}
        @visible_fields = [:id, :ip, :group, :note]
        @input_fields = [:ip, :hostname, :user, :port, :options, :note, :group, :connect_via]
        @column_width = 15 #TODO make this dynamic or a yaml setting
      end

      def check_connection_type(connection)
        if connection.class == String
          "hostname"
        else
          "ip"
        end
      end

      def connect_to(id)
        id.each do |conn|
          conn.to_i
          ssh_command = ""
          i = conn
          begin
            connection = DATABASE.get_connection_by_id(i)
            ip = connection[:ip]
            user = connection[:user]
            user = ENV['USER'] if user == ""
            options = connection[:options]
            via = connection[:connect_via]
            ssh_command = "ssh -A -t #{options} #{user}@#{ip} #{ssh_command}"
            i = via
            #TODO prevent endless via-loops
          end while via
          connection[:count] += 1
          connection[:last_time] = Time.now
          DATABASE.update_connection(connection)
          if CONFIG['target'] == "self"
            exec ssh_command
          elsif CONFIG['terminal'] == "xfce4-terminal" || CONFIG['terminal'] == "gnome-terminal"
            if CONFIG['tabbed'] == 'true'
              command = "--title=#{user}@#{ip} --tab --command="
            else
              command = "--title=#{user}@#{ip} --command="
            end
            #TODO: add title --title='connection name to identify '
            #TODO: bug when no terminal is open => wants to open 2 terms
            #TODO: dnslookup
            %x(#{CONFIG['terminal']} #{command}"#{ssh_command}")
          elsif CONFIG['terminal'] == "xterm" || CONFIG['terminal'] == "urxvt"
            %x(#{CONFIG['terminal']} -e "#{ssh_command}")
          else
            puts "We dont support #{CONFIG['terminal']} right now"
            puts 'Check Github for further development or contributing'
          end
        end
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

      def show_info(id)
        @input_fields << :count
        @input_fields << :last_time
        id.each do |conn|
          connections = DATABASE.get_connection_by_id(conn.to_i)
          puts "\n"
          @input_fields.each do |field|
            if field == :connect_via && connections[field] != nil
              via_ip = DATABASE.get_connection_by_id(connections[field])[:ip]
              printf "%s: %s  -|-  %s ", field, connections[field], via_ip
            else
              printf "%s: %s", field, connections[field]
            end
            puts "\n"
          end
        end
      end

      def transfer_key(id)
        #TODO connect_via
        #TODO options
        connection = DATABASE.get_connection_by_id(id)
        user = connection[:user]
        user = ENV['USER'] if user == ""
        %x(ssh-copy-id #{user}@#{connection[:ip]})
      end

      def ping(id)
        connection = DATABASE.get_connection_by_id(id)
        if connection[:connect_via]
          connect_via = DATABASE.get_connection_by_id(connection[:connect_via])
          ssh = "ssh #{connect_via[:user]}@#{connect_via[:ip]}"
          exec("#{ssh} ping #{connection[:ip]} -c 3")
        else
          exec("ping #{connection[:ip]} -c 3")
        end
      end


      def test(id)
      end

      def transfer_file(filename, id='', dest_path="/home/#{user}/")
        #TODO connect_via
        #TODO options
        connection = DATABASE.get_connection_by_id(id)
        user = connection[:user]
        user = ENV['USER'] if user == ""
        %x(scp #{filename} #{user}@#{connection[:ip]}:#{dest_path}) if File.file?(filename)
        %x(scp -r #{filename} #{@user}@#{connection[:ip]}:#{dest_path}) if File.directory?(filename)
      end

      def add_connection
        connection = {:user => ENV['USER'],
                      :port => "22"}
        @input_fields.each do |key|
          #TODO make this a method
          connection[key] = %x{source #{File.dirname(__FILE__)}/ask.sh; ask '#{@pretty_names[key]}' '#{connection[key]}'}.chomp
        end
        connection[:count] = 0
        connection[:created_at] = Time.now.to_s
        connection[:last_time] = Time.now.to_s
        connection[:connect_via] = nil if connection[:connect_via] == ""
        DATABASE.add_new_connection(connection)
        #TODO catch SQLite3::ConstraintException
      end

      def delete(id)
        id.each do |conn|
          conn.to_i
          DATABASE.delete_connection(conn)
        end
      end

      def list_all
        connections = DATABASE.get_connection_data
        @visible_fields.each { |f| printf "%-#{@column_width}s", @pretty_names[f] }
        puts "\n"
        connections.each do |c|
          @visible_fields.each { |f| printf "%-#{@column_width}s", c[f] }
          puts "\n"
        end
      end

      def update(id)
        connection = DATABASE.get_connection_by_id(id)
        @input_fields.each do |key|
          #TODO make this a method
          connection[key] = %x{source #{File.dirname(__FILE__)}/ask.sh; ask '#{@pretty_names[key]}' '#{connection[key]}'}.chomp
        end
        connection[:connect_via] = nil if connection[:connect_via] == ""
        DATABASE.update_connection(connection)
        #TODO catch SQLite3::ConstraintException
      end

      def search_for(term)
        puts "All results for searchterm: #{term}"
        @visible_fields.each { |f| printf "%-#{@column_width}s", @pretty_names[f] }
        print "\n"
        DATABASE.search_for(term).each do |x|
          x.all.each do |cons|
            @visible_fields.each { |f| printf "%-#{@column_width}s", cons[f] }
            puts "\n"
          end
        end
      end

      def multiple_connection(term)
        DATABASE.search_for(term).each do |x|
          x.all.each do |dataset|
            self.connect_to([dataset[:id]])
          end
        end
      end
    end
  end
end

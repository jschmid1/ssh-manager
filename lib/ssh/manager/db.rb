require 'sequel'
require 'fileutils'

module SSH
  module Manager
    class Database

      FileUtils.mkdir_p("#{File.join(ENV['HOME'])}/.config/sshm/") unless Dir.exists?("#{ENV['HOME']}/.config/sshm")
      FileUtils.cp ("#{File.dirname(__FILE__)}/../../../config/sshm.db"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/sshm.db'))

      @path = "#{File.join(ENV['HOME'])}/.config/sshm"
      DATABASE = Sequel.connect("sqlite://#{@path}/sshm.db")

      attr_accessor :connections

      def initialize
        @connections= DATABASE.from(:connection)
      end

      def get_connection_data
        @connections.map([:ip, :user, :note, :group, :connect_via])
      end

      def add_new_connection(ip, user='root', hostname='', port=22, note='', created_at, option, count, group, last_time)
        @connections.insert(:ip => ip, :user => user, :hostname => hostname, :port => port, :note => note, :created_at => created_at, :options => option, :group => group, :count => count, :last_time => last_time)
      end

      def delete_connection(ip)
        # add && :user => user to ensure deletion
        @connections.where(:ip => ip).delete
      end

      def update_connection(ip, user, hostname, port, note)
        @connections.where(:ip => ip).update(:user => user, :hostname => hostname, :port => port, :note => note)
      end

      def search_for(term)
        # check online: search for 'contains' not for complete matching
        return  @connections.where(:ip => term),  @connections.where(:user => term), @connections.where(:hostname => term), @connections.where(:port => term), @connections.where(:note => term), @connections.where(:group => term), @connections.where(:options => term)
      end


    end
  end
end

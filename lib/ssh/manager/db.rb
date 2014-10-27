require 'sequel'
require 'fileutils'

module SSH
  module Manager
    class Database

      FileUtils.cp ("#{File.dirname(__FILE__)}/../../../config/sshm.db"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/sshm.db'))
      FileUtils.mkdir_p("#{File.join(ENV['HOME'])}/.config/sshm/") unless Dir.exists?("#{ENV['HOME']}/.config/sshm")

      @path = "#{File.join(ENV['HOME'])}/.config/sshm"
      DATABASE = Sequel.connect("sqlite://#{@path}/sshm.db")

      attr_accessor :connections

      def initialize
        @connections= DATABASE.from(:connection)
      end

      def get_connection_data
        @connections.map([:ip, :user, :hostname, :port, :note])
      end

      def add_new_connection(ip, user='root', hostname='', port=22, note='')
        # default params are currently useless FIXME
        @connections.insert(:ip => ip, :user => user, :hostname => hostname, :port => port, :note => note)
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
        return  @connections.where(:ip => term),  @connections.where(:user => term), @connections.where(:hostname => term), @connections.where(:port => term), @connections.where(:note => term)
      end

    end
  end
end

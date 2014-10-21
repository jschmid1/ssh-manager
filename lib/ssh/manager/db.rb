require 'sequel'
require 'fileutils'
module SSH
  module Manager
    class Database
    FileUtils.mkdir_p("#{File.join(ENV['HOME'])}/.config/sshm/") unless Dir.exists?("#{ENV['HOME']}/.config/sshm")
    FileUtils.cp ("#{File.dirname(__FILE__)}/../../sshm.db"), ("#{File.join(Dir.home)}" + '/.config/sshm/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/sshm/sshm.db'))

    @path = "#{File.join(ENV['HOME'])}/.config/sshm"
    DATABASE = Sequel.connect("sqlite://#{@path}/sshm.db")

    attr_accessor :connections

    def initialize
      @connections= DATABASE.from(:connection)
    end

    def get_connection_data
      @connections.map([:ip, :user, :hostname, :port])
    end

    end
  end
end

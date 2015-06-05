require 'sequel'
require 'fileutils'

module SSH
  module Manager
    class Database

      @config_dir = "#{ENV['HOME']}/.config/sshm"
      FileUtils.mkdir_p(@config_dir) unless Dir.exists?(@config_dir)

      @database_file = "#{@config_dir}/sshm.sqlite3"
      unless File.exists?(@database_file)
        Sequel.sqlite(@database_file).run <<-NEW_DB
CREATE TABLE connection (
   "id"           INTEGER PRIMARY KEY AUTOINCREMENT,
   "ip"           TEXT,
   "user"         TEXT,
   "hostname"     TEXT,
   "port"         INTEGER,
   "note"         TEXT,
   "created_at"   TEXT,
   "options"      TEXT,
   "group"        TEXT,
   "count"        INTEGER,
   "last_time"    TEXT,
   "secure_check" INTEGER,
   "connect_via"  INTEGER NULL,
   FOREIGN KEY("connect_via") REFERENCES connection("id")
);

INSERT INTO connection ("ip", "hostname") VALUES ("127.0.0.1", "localhost");
NEW_DB
        #TODO make group a n:m relation to extra table
      end
      DATABASE = Sequel.sqlite(@database_file)

      attr_accessor :connections

      def initialize
        @connections = DATABASE[:connection]
      end

      def get_connection_by_id(id)
        @connections[:id => id].to_hash
      end

      def get_connection_data
        @connections.all
      end

      def add_new_connection(connection)
        @connections.insert(connection)
      end

      def delete_connection(id)
        @connections.where(:id => id).delete
      end

      def update_connection(connection)
        @connections.where(:id => connection[:id]).update(connection)
      end

      def search_for(term)
        # check online: search for 'contains' not for complete matching
        return  @connections.where(:ip => term),  @connections.where(:user => term), @connections.where(:hostname => term), @connections.where(:port => term), @connections.where(:note => term), @connections.where(:group => term), @connections.where(:options => term)
      end
    end
  end
end

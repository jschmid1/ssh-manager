#require_relative "../manager"
require 'optparse'
require_relative 'db'
require_relative 'client'
require_relative 'version'

module SSH
  module Manager
    class Client

      attr_accessor :options

      def initialize(argv)
        @options = {}
        @argv = argv
        extract_options
      end

      def execute!
        cli = SSH::Manager::Cli
        # TODO id.to_i is not good enough. we want to support hostnames too
        if @options[:add]
          puts 'Adding ..'
          cli.new(@options).add_connection
        elsif @options[:connect]
          puts 'Connecting ..'
          cli.new(@options).connect_to(@options[:connect].to_i)
        elsif @options[:transfer_file]
          puts 'Transfering file..'
          cli.new(@options).transfer_file(@options[:transfer_file].to_i, @argv[2], @argv[3])
        elsif @options[:delete]
          puts 'Deleting ..'
          cli.new(@options).delete(@options[:delete].to_i)
        elsif @options[:list]
          puts 'Listing ..'
          cli.new(@options).list_all
        elsif @options[:upgrade]
          puts 'Checking for new updates ..'
          cli.new(@options).update_available
        elsif @options[:update]
          puts 'Updating ..'
          cli.new(@options).update(@options[:update].to_i)
        elsif @options[:multi]
          puts 'Connecting to multiple ips..'
          cli.new(@options).multiple_connection(@options[:multi])
        elsif @options[:transfer_key]
          puts 'Transfering key..'
          cli.new(@options).transfer_key(@options[:transfer_key].to_i)
        elsif @options[:search]
          puts 'Searching ..'
          cli.new(@options).search_for(@options[:search])
        # elsif @options[:settings]
        #   puts 'Settings'
        #   cli.new(@options).settings(@options[:settings])
        else
          cli.new(@argv.first).connect_to(@argv.first) if @argv != []
          puts @optparse if @argv ==[]
          exit
        end
      end

      def extract_options
        @optparse = OptionParser.new do |opts|
          opts.banner = "Usage: sshm [options] ..."
          @options[:add] = false
          opts.on( '-a', '--add', 'add a new connection' ) do
            @options[:add] = true
          end
          @options[:transfer_key] = false
          opts.on( '-t', '--transferkey id', 'transfer key to <id>' ) do |opt|
            @options[:transfer_key] = opt
          end
          @options[:transfer_file] = false
          opts.on( '-r', '--transferfile filename', 'file or dir / connection_ID / dest_path(default is /home/user/)' ) do |opt|
            @options[:transfer_file] = opt
          end
          @options[:connect] = false
          opts.on( '-c', '--connect id', 'connect to <id>' ) do |opt|
            @options[:connect] = opt
          end
          @options[:delete] = false
          opts.on( '-d', '--delete id', 'delete connection <id>' ) do |opt|
            @options[:delete] = opt
          end
          @options[:update] = false
          opts.on( '-u', '--update id', 'update connection <id>' ) do |opt|
            @options[:update] = opt
          end
          @options[:search] = false
          opts.on( '-s', '--search string', 'search connection for given criteria' ) do |opt|
            @options[:search] = opt
          end
          @options[:multi] = false
          opts.on( '-m', '--multi string', 'connect to multiple ips with given criteria' ) do |opt|
            @options[:multi] = opt
          end
          @options[:list] = false
          opts.on( '-l', '--list', 'list all connections' ) do
            @options[:list] = true
          end
          @options[:upgrade] = false
          opts.on( '-g', '--upgrade', 'checks for upgrade' ) do
            @options[:upgrade] = true
          end
          opts.on( '-h', '--help', 'display this screen' ) do
            puts opts
            exit
          end
          opts.on( '-v', '--version', 'print programs version' ) do
            puts SSH::Manager::VERSION
            exit
          end
        end
        @optparse.parse(@argv)
      end
    end
  end
end


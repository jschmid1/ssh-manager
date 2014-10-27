#require_relative "../manager"
require 'optparse'
require_relative 'db'
require_relative 'client'

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
        if @options[:add]
          puts 'Adding ..'
          cli.new(@options).add_connection(@options[:add])
        elsif @options[:connect]
          puts 'Connecting ..'
          cli.new(@options).connect_to(@options[:connect])
        elsif @options[:delete]
          puts 'Deleting ..'
          cli.new(@options).delete(@options[:delete])
        elsif @options[:list]
          puts 'Listing ..'
          cli.new(@options).list_all
        elsif @options[:update]
          puts 'Updating ..'
          cli.new(@options).update(@options[:update])
        elsif @options[:multi]
          puts 'Connecting to multiple ips'
          cli.new(@options).multiple_connection(@options[:multi])
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
          opts.on( '-a', '--add ip', 'Add ip to your Connection list' ) do |opt|
            @options[:add] = opt
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
          opts.on( '-h', '--help', 'Display this screen' ) do
            puts opts
            exit
          end
          opts.on( '-v', '--version', 'Print programs version' ) do
            puts SSH::Manager::VERSION
            exit
          end
        end
        @optparse.parse(@argv)
      end
    end
  end
end


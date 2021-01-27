# frozen_string_literal: true

require_relative "service/version"
require "fileutils"
require "logger"

module App
  class Service
    class Error < StandardError; end

    PROGRAM_DIR  =  File.expand_path( File.dirname( $PROGRAM_NAME ) )

    class << self
      def setup( mode = nil, argv: ARGV, app_dir: nil, tmp_dir: nil, log_dir: nil, **options )
        setup_vars( mode, argv, app_dir, tmp_dir, log_dir, options[:progname] )

        case  @@mode
        when  "run"
          if alive?
            puts  "already in alive."
            ::Kernel.exit
          end
          setup_logger( **options )

        when  "start"
          if alive?
           #puts  "already in alive."
            ::Kernel.exit
          end
          Process.daemon( true, true )
          setup_service
          setup_logger( log_path: @@log_path, **options )

        when  "restart"
          while  alive?
            request_to_stop
            ::Kernel.sleep( 1 )
          end
          Process.daemon( true, true )
          setup_service
          setup_logger( log_path: @@log_path, **options )

        when  "stop"
          while  alive?
            request_to_stop
            ::Kernel.sleep( 1 )
          end
          # puts  "successed to stop."
          ::Kernel.exit

        when  "status"
          if alive?
            puts  "in alive."
          else
            puts  "not in alive."
          end
          ::Kernel.exit

        end
      end

      def shutdown( cond = 0 )
        delete_pid_path
        ::Kernel.exit( cond )
      end

      def logger
        @@logger
      end

      def mode
        @@mode
      end

    private

      def setup_vars( mode, argv, app_dir, tmp_dir, log_dir, progname )
        if mode.nil?
          @@mode  =  argv.dup.shift.to_s.downcase
        else
          @@mode  =  mode.to_s.downcase
        end

        @@progname  =  progname || File.basename( $PROGRAM_NAME, '.rb' )
        unless  %w[ run start stop restart status ].include?( @@mode )
          STDERR.puts <<~USAGE
          usage: #{@@progname}  [run|start|stop|restart|status]
          USAGE
          ::Kernel.exit( 1 )
        end

        if ( !app_dir.nil? && app_dir[0] == "/" )
          @@app_dir  =  app_dir
        else
          @@app_dir  =  File.expand_path( File.join( PROGRAM_DIR, ( app_dir || "." ) ) )
        end
        Dir.chdir( @@app_dir )

        if ( !tmp_dir.nil? && tmp_dir[0] == "/" )
          @@tmp_dir  =  tmp_dir
        else
          @@tmp_dir  =  File.expand_path( File.join( @@app_dir, ( tmp_dir || "." ) ) )
        end
        unless  Dir.exist?( @@tmp_dir )
          FileUtils.makedirs( @@tmp_dir )
        end

        @@pid_path  =  File.expand_path( File.join( @@tmp_dir, @@progname + ".pid" ) )

        if ( !log_dir.nil? && log_dir[0] == "/" )
          @@log_dir  =  log_dir
        else
          @@log_dir  =  File.expand_path( File.join( @@app_dir, ( log_dir || "." ) ) )
        end

        unless  Dir.exist?( @@log_dir )
          FileUtils.makedirs( @@log_dir )
        end

        @@log_path  =  File.expand_path( File.join( @@log_dir, @@progname + ".log" ) )
      end

      def setup_service
        File.open( @@pid_path, "w" ) do |f|
          f.puts( Process.pid )
        end
        $0  =  "[#{ @@progname }]"
      end

      def delete_pid_path
        if  File.exist?( @@pid_path )
          File.delete( @@pid_path )
        end
      end

      def setup_logger( log_path: nil, shift_age: nil, shift_size: nil, log_sync: nil, **options )
        sync  =  ( log_sync.nil? ? true : log_sync )
        if  log_path
          if shift_age && shift_size
            @@logger  =  ::Logger.new( log_path, shift_age, shift_size.to_i, **options )
          elsif shift_age && shift_size.nil?
            @@logger  =  ::Logger.new( log_path, shift_age, **options )
          else
            @@logger  =  ::Logger.new( log_path, **options )
          end

          dev  =  @@logger.instance_variable_get(:@logdev).dev
          $stdout.reopen  dev
          $stdout.sync  =  sync
          $stderr.reopen  dev
          $stderr.sync  =  sync
        else
          @@logger  =  ::Logger.new( STDOUT, **options )
          STDOUT.sync  =  sync
        end
      end

      # send INT signal to background process.
      def request_to_stop
        pid  =  File.open( @@pid_path ).read.to_i    rescue  raise( ArgumentError, "could not load '#{ @@pid_path }'." )
        Process.kill( :INT, pid )                    rescue  raise( ArgumentError, "could not send signal." )
      rescue => e
        puts  e.message
      end

      def alive?
        result  =  true
        begin
          pid  =  File.open( @@pid_path ).read.to_i
          Process.kill( 0, pid )
        rescue => e
          result  =  false
        end
        result
      end
    end

  end
end


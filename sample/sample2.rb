require "app/service"

options = {
# app_dir:              "..",
# tmp_dir:              "tmp",
# log_dir:              "log",
# log_sync:             true,   # Boolean

# shift_age:            0,      # 0, Positive, "daily", "weekly", "monthly"
# shift_size:           1048576,# Positive
# level:                Logger::Severity::DEBUG,
                                # 0:DEBUG, 1:INFO, 2:WARN, 3:ERROR, 4:FATAL, 5:UNKNOWN
# progname:             nil,
# formatter:            Formatter.new,
# datetime_format:      '%Y-%m-%d %H:%M:%S', 
# shift_period_suffix:  '%Y%m%d',
}

App::Service.setup( ARGV.shift, **options )

logger  =  App::Service.logger
logger.info  App::Service.mode
sleep  1
logger.info  "quit"


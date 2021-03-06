require 'logger'

module Log
  LOG_LEVEL_NAMES = [:DEBUG, :INFO, :WARNING, :ERROR, :FATAL, :UNKNOWN]

  class << self
    attr_accessor :log

    def level=(level)
      level = LOG_LEVEL_NAMES.index(level) if level.is_a? Symbol
      log.level = level
      log.info "Enabled logging at #{LOG_LEVEL_NAMES[log.level]} level"
    end
  end

  def log; Log::log; end

  self.log = Logger.new(STDERR)
  log.formatter = lambda do |type, time, progname, message|
    $stderr.puts "[#{time} #{type.rjust(5)}] #{progname ? "#{progname}: ": ''}#{message}"
  end
end





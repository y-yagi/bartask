require "optparse"
require "bartask/version"

class Bartask::Cli
  class << self
    def start(argv = ARGV)
      cli = new(argv)
      options = cli.parse

      return if options[:version_shown]

      if options[:mode] == "r"
        Bartask::Restorer.new(config_file_path: options[:config], dump_file_path: options[:dump]).execute
      else
        Bartask::Dumper.new(config_file_path: options[:config], dump_file_path: options[:dump]).execute
      end
    end
  end

  CMD = "bartask"
  USAGE = <<~USAGE
  sub commands are:
     d :     dump DB data
     r :     restore DB data
  See '#{CMD} COMMAND --help' for more information on a specific command.
  USAGE

  def initialize(argv)
    @argv = argv
    @options = {}
  end

  def parse
    global_command.order!(@argv)
    return @options if @options[:version_shown]

    @options[:mode] = @argv.shift
    subcommand = subcommands[@options[:mode]]
    unless subcommand
      puts global_command.help
      exit!
    end

    subcommand.order!(@argv)
    @options
  end

  private

  def global_command
    @global_command ||= OptionParser.new do |opts|
      opts.banner = "Usage: #{CMD} [subcommand] [options]"
      opts.separator ""
      opts.separator USAGE

      opts.on("-v", "--version", "Show version") do
        puts Bartask::VERSION
        @options[:version_shown] = true
      end
    end
  end

  def subcommands
    {
      'd' => OptionParser.new do |opts|
        opts.banner = "Usage: #{CMD} d [options]"

        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end

        opts.on("-D", "--dump PATH", "Dump file path") do |v|
          @options[:dump] = v
        end
      end,
      'r' => OptionParser.new do |opts|
        opts.banner = "Usage: #{CMD} r [options]"

        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end

        opts.on("-D", "--dump PATH", "Dump file path") do |v|
          @options[:dump] = v
        end
      end
    }
  end
end

require "optparse"

class Bartask::Cli
  class << self
    def start(argv = ARGV)
      cli = new(argv)
      options = cli.parse

      if options[:mode] == "r"
        Bartask::Restorer.new(config_file_path: options[:config]).execute
      else
        Bartask::Dumper.new(config_file_path: options[:config]).execute
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
      opts.banner = "Usage: #{CMD} [options] [subcommand [options]]"
      opts.separator ""
      opts.separator USAGE
    end
  end

  def subcommands
    {
      'd' => OptionParser.new do |opts|
        opts.banner = "Usage: #{CMD} d [options]"

        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end
      end,
      'r' => OptionParser.new do |opts|
        opts.banner = "Usage: #{CMD} r [options]"

        opts.on("-C", "--config PATH", "Config file path") do |v|
          @options[:config] = v
        end
      end
    }
  end
end

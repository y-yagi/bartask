# frozen_string_literal: true

module Bartask
  class Dumper < Base
    def execute
      unless confirm("Are you sure you want to dump the database to '#{dump_file_path}'?")
        $stdout.puts "Dump operation cancelled."
        return
      end

      if mysql?
        system("mysqldump #{build_options_for_mysql.join(' ')} > #{dump_file_path}")
      elsif postgresql?
        system(env_for_postgresql, "pg_dump #{build_options_for_postgres.join(' ')} --format=c > #{dump_file_path}", exception: true)
      else
        raise ArgumentError, "Unsuported adapter: #{@config["adapter"]}"
      end
      $stdout.puts "Dumped to '#{dump_file_path}'."
    end
  end
end

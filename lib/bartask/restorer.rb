# frozen_string_literal: true

module Bartask
  class Restorer < Base
    def execute
      if mysql?
        system("mysql #{build_options_for_mysql.join(' ')} < #{dump_file_path}", exception: true)
      elsif postgresql?
        system(env_for_postgresql, "pg_restore #{build_options_for_postgres.join(' ')} --dbname #{@config["database"]} #{dump_file_path}", exception: true)
      else
        raise ArgumentError, "Unsuported adapter: #{@config["adapter"]}"
      end
      $stdout.puts "Restored from '#{dump_file_path}'."
    end
  end
end

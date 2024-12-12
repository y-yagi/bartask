# frozen_string_literal: true

require "active_support"
require "active_support/configuration_file"
require "pathname"
require "open3"

module Bartask
  class Base
    def initialize(config_file_path: nil)
      @config_file_path = config_file_path || Pathname.new("config/database.yml")
      parse_config_file
    end

    def dump_file_path
      @dump_file_path ||= begin
        suffix = branch_name.empty? ? "" : "_#{branch_name}"
        Pathname.new("tmp/#{@config["database"]}#{suffix}.dump")
      end
    end

    private

    def parse_config_file
      @config = ActiveSupport::ConfigurationFile.parse(@config_file_path)["development"]
    end

    def mysql?
      @config["adapter"] == "mysql2" || @config["adapter"] == "trilogy"
    end

    def postgresql?
      @config["adapter"] == "postgresql"
    end

    def env_for_postgresql
      @config["password"] ? { "PGPASSWORD" => @config["password"]} : {}
    end

    def branch_name
      @branch_name ||= begin
        stdout, _, _ = Open3.capture3("git name-rev --name-only HEAD")
        stdout.strip.gsub("/", "_")
      end
    end

    def build_options_for_mysql
      options = []
      options << "--user=#{@config["username"]}" if @config["username"]
      %w[password host port socker].each do |key|
        options << "--#{key}=#{@config[key]}" if @config[key]
      end
      options << @config["database"]
      options
    end

    def build_options_for_postgres
      options = []
      %w[username host port].each do |key|
        options << "--#{key}=#{@config[key]}" if @config[key]
      end
      options.push(*%w[--clean --no-owner --no-acl])
      options
    end
  end
end

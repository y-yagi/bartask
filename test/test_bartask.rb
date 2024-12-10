# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "open3"

class TestBartask < Minitest::Test
  def test_mysql
    Dir.chdir("test/dummy_application") do
      FileUtils.cp "config/database_mysql.yml", "config/database.yml"
      dump_and_restore
    end
  end

  def test_postgresql
    Dir.chdir("test/dummy_application") do
      FileUtils.cp "config/database_postgresql.yml", "config/database.yml"
      dump_and_restore
    end
  end

  def dump_and_restore
    system("bin/rails db:drop db:create db:migrate db:seed", exception: true)
    stdout, _, _ = Open3.capture3("bin/rails r 'puts User.count'")
    assert_equal "3", stdout.strip

    system("bundle exec ../../exe/bartask d", exception: true)
    assert File.exist?("tmp/dummy_application_development_main.dump")

    system("bundle exec ../../exe/bartask r", exception: true)
    stdout, _, _ = Open3.capture3("bin/rails r 'puts User.count'")
    assert_equal "3", stdout.strip
  end
end

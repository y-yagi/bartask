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

  def test_postgresql_with_dump_option
    Dir.chdir("test/dummy_application") do
      FileUtils.cp "config/database_postgresql.yml", "config/database.yml"

      setup_db

      system("bundle exec ../../exe/bartask d --dump tmp/bartask.dump", exception: true)
      assert File.exist?("tmp/bartask.dump"), Dir["tmp/*"].inspect

      system("bundle exec ../../exe/bartask r --dump tmp/bartask.dump", exception: true)
      assert_db_data
    end
  end

  private

  def dump_and_restore
    setup_db
    assert_db_data

    system("bundle exec ../../exe/bartask d", exception: true)
    assert !Dir.glob("tmp/dummy_application_development_*.dump").empty?, Dir["tmp/*"].inspect

    system("bundle exec ../../exe/bartask r", exception: true)
    assert_db_data
  end

  def setup_db
    system("bin/rails db:drop db:create db:migrate db:seed", exception: true)
  end

  def assert_db_data
    stdout, _, _ = Open3.capture3("bin/rails r 'puts User.count'")
    assert_equal "3", stdout.strip
  end
end

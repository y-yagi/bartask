# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bartask"
require "debug"

require "minitest/autorun"

# Skip confirmation dialogs during tests
ENV["BARTASK_SKIP_CONFIRM"] = "true"

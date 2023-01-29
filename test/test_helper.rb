# frozen_string_literal: true

if RUBY_ENGINE != "truffleruby"
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch
    primary_coverage :branch
  end
end

if RUBY_ENGINE == "truffleruby"
  require "set" # rubocop:disable all
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pairing_heap"

require "minitest/autorun"

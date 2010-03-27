require 'rubygems'
require 'saint_peter'
require 'test/unit'
require 'rack/test'
require 'shoulda'

set :environment, :test

class Test::Unit::TestCase
  def self.setup(&block)
    define_method(:setup, &block)
  end

  def self.teardown(&block)
    define_method(:teardown, &block)
  end

  def self.test(name, &block)
    define_method("test: #{name} ", &block)
  end
end

class Object
  def debug
    require 'ruby-debug'; debugger
  end
end

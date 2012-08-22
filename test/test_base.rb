gem 'test-unit'
require 'test/unit'
require 'yaml'
begin
  require File.join(File.dirname(__FILE__), '../lib/ocm')
rescue Exception => ex
  puts "Could NOT load gem: " + ex.message
  raise ex
end

class TestBase < Test::Unit::TestCase

  def setup
    puts 'setup'

  end

end

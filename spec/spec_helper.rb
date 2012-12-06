require "bundler/setup"

require "simplecov"
SimpleCov.start do
  add_group "Libraries", "/lib"
end

require "subtle"

RSpec.configure do |config|
end

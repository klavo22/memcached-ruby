require "rspec"
require "rspec-benchmark"


RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers

  config.before(:all) do
    @thread = Thread.new { Server.new(1892).start }
  end

  config.after(:all) do
    Thread.kill(@thread)
  end
end
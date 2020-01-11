require 'benchmark'
require 'memcache'
require_relative '../server'

thread = Thread.new { Server.new(1891).start }

n = 10

Benchmark.bm do |x|
  x.report "set:" do
    client = MemCache.new 'localhost:1891'

    n.times.each do |time|
      client.set("key#{time}", 'test', 0, true)
    end
  end

  x.report "simultaneously set:" do 
    Server::CACHE.flush_all

    n.times.map do |time|
      Thread.new do
        client = MemCache.new 'localhost:1891'
        client.set("key#{time}", 'test', 0, true)
      end
    end.each &:join
  end
end
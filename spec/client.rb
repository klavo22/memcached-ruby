require 'memcache'
require 'byebug'

class Client

  def initialize(port)
    @client = MemCache.new "localhost:#{port}"    
  end

  def send_msg(msg)
    options = msg.split
    command = options.shift.to_sym
    case command
    when :set, :add, :replace 
      @client.send(command, *options, true)
    when :get, :gets
      @client.send(command, *options, raw: true)
    when :append, :prepend 
      @client.send(command, *options)
    end
  end

end


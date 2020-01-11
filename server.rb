require "socket"
require "byebug"

require_relative "lib/cache"
require_relative "lib/logger"

require_relative "commands/storage"
require_relative "commands/retrieval"

class Server
  CACHE = Cache.new

  def initialize(port)
    @server = TCPServer.new port
  end

  def start
    port = @server.local_address.ip_port
    puts "Memcached server is started at port #{port}"

    loop do
      Thread.start(@server.accept) do |client|  
        puts "\nClient connected...\n\n"

        loop do
          input = client.gets
          Logger.info(input)

          input = input.split

          command = input.first

          close if command == "quit"

          command_class = command.match?(/^get/) ? Commands::Retrieval : Commands::Storage 

          command_class.new(client, input).call

        end
      end
    end
  end

  def close
    @server.close
  end 

end



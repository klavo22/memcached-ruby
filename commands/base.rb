module Commands
  class Base
    def initialize(client, options)
      @client  = client
      @options = options
    end

    private

    def client_gets
      @client.gets.chomp
    end

    def client_puts(value)
      @client.puts "#{value}\r\n"
    end
  end
end

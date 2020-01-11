require_relative "base"

module Commands
  class Retrieval < Base
    def call
      
      command = @options.first
      key = @options[1]

      return client_puts "ERROR" if error?

      record = Server::CACHE.get(key)

      if record
        id = command == "gets" ? " #{record[:cas_token]}" : ''
        
        client_puts "VALUE #{key} #{record[:flags]} #{record[:bytes]}#{id}"
        client_puts record[:value] 
      end

      client_puts "END"
    end

    private 

    def error?
      !Server::CACHE.respond_to?(@options.first) || @options[1].empty?
    end

  end
end
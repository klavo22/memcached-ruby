require_relative "base"

module Commands
  class Retrieval < Base
    def call
      
      command = @options.first
      key = @options[1]

      record = if Server::CACHE.respond_to?(command)
        Server::CACHE.get(key)
      else
        "CLIENT_ERROR"
      end

       if record
        id = command == "gets" ? " #{record[:cas_token]}" : ''
        
        client_puts "VALUE #{key} #{record[:flags]} #{record[:bytes]}#{id}"
        client_puts record[:value] 
      end

      client_puts "END"
    end

  end
end
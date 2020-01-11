require_relative "base"
require_relative "storage/validator"

module Commands
  class Storage < Base
    def call

      command = @options[0]
      options = prettify_options
      validator = Validator.new(command, options)

      return client_puts("ERROR") if validator.error?
      return client_puts("CLIENT_ERROR bad command line format") if validator.client_error?

      value = client_gets
      
      Logger.info(value, add: true)

      if validator.invalid_bytes?(value)
        return client_puts("CLIENT_ERROR bad data chunk")
      end

      response = Server::CACHE.send(command, { value: value, **options})

      if command != "cas" && @options[5] != 'noreply'
        client_puts "#{response}"
      elsif command == "cas" && @options[6] != 'noreply'
        client_puts "#{response}"
      end
    end

    private

    def prettify_options
      {   
        key:       @options[1],
        flags:     @options[2],
        exptime:   @options[3],
        bytes:     @options[4],
        cas_token: @options[0] == "cas" ? @options[5] : "0"
      }
    end

  end
end
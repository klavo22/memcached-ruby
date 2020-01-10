require_relative "base"

module Commands
  class Storage < Base
    def call
      value = client_gets
      
      Logger.info(value, add: true)
      
      command = @options.first

      response = if Server::CACHE.respond_to?(command) && valid?(options, value)
          Server::CACHE.send(command, { value: value, **options})
      else
        "CLIENT_ERROR"
      end

      if command != "cas" && @options[5] != 'noreply'
        client_puts "#{response}"
      elsif command == "cas" && @options[6] != 'noreply'
        client_puts "#{response}"
      end
    end

    private

    def options
      {   
        key:       @options[1],
        flags:     @options[2],
        exptime:   @options[3],
        bytes:     @options[4],
        cas_token: @options[0] == "cas" ? @options[5] : "0"
      }
    end

    def valid?(options, value)
      return false unless !params_are_blank?
      return false unless value.size.eql?(options[:bytes].to_i) 
      return false unless is_int?(options[:exptime]) 
      return false unless is_int?(options[:flags])
      if cas?
        return false unless is_int?(options[:cas_token], positive: false)
      end
      true
    end
    

    def params_are_blank?
      
      keys = [:key, :flags, :exptime, :bytes]
      keys.push(:cas_token) if cas?
      
      keys.any? do |key|
        options[key].nil? || options[key].empty?
      end
    end

    def cas?
      @options[0] == "cas"
    end

    def is_int?(value, positive: true)
      if positive
        !value.match(/^\d+$/).nil?
      else
        !value.match(/^(-?)\d+$/).nil?
      end
    end

  end
end
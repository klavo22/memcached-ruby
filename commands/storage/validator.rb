class Validator
  MAX_32_BIT_UNSIGNED = 4294967295
  MAX_64_BIT_UNSIGNED = 18446744073709551615

  def initialize(command, options)
    @command = command
    @options = options
  end

  def error?
    !Server::CACHE.respond_to?(@command) || params_are_blank?
  end

  def client_error?
    values_are_not_int? || invalid_flags? || ( cas? && invalid_token? )
  end

  def invalid_bytes?(value)
    value.size != @options[:bytes].to_i
  end

  private

  def params_are_blank?
    keys = [:key, :flags, :exptime, :bytes]
    keys.push(:cas_token) if cas?

    keys.any? do |key|
      @options[key].nil? || @options[key].empty?
    end
  end

  def values_are_not_int?
    return true unless is_int?(@options[:flags])
    return true unless is_int?(@options[:exptime], allow_negative: true)
    return true unless is_int?(@options[:bytes])
    return false
  end

  def is_int?(value, allow_negative: false)
    if allow_negative == false
      return !value.match(/^\d+$/).nil?
    else
      return !value.match(/^(-?)\d+$/).nil?
    end
  end

  def invalid_flags?
    @options[:flags].to_i > MAX_32_BIT_UNSIGNED
  end

  def invalid_token?
    @options[:cas_token].to_i > MAX_64_BIT_UNSIGNED
  end

  def cas?
    @command == "cas"
  end
end

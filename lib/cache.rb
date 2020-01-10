class Cache

  STORED     = "STORED"
  NOT_STORED = "NOT_STORED"
  NOT_FOUND  = "NOT_FOUND"
  EXISTS     = "EXISTS"

  def initialize
    @keys = {}
    @last_token = 0
  end

  def set(key:, **data)
    @keys[key] = data
    set_token(key)
    set_exptime(key, data)
    STORED
  end

  def add(key:, **data)
    if !valid_key?(key)
      @keys[key] = data
      set_token(key)
      set_exptime(key, data)
      STORED
    else
      NOT_STORED
    end
  end

  def replace(key:, **data)
    if valid_key?(key)
      @keys[key].merge!(data)
      set_token(key)
      set_exptime(key, data)
      STORED
    else
      NOT_STORED
    end
  end

  def append(key:, **data)
    if valid_key?(key)
      set_values(:concat, key, data)
      set_token(key)
      STORED
    else
      NOT_STORED
    end
  end

  def prepend(key:, **data)
    if valid_key?(key)
      set_values(:prepend, key, data)
      set_token(key)
      STORED
    else
      NOT_STORED
    end
  end

  def cas(key:, **data)
    if valid_key?(key) 
      if @keys[key][:cas_token] == data[:cas_token].to_i
        replace(key:key, **data)
        STORED
      else
        EXISTS
      end
    else
      NOT_FOUND
    end
  end

  def get(key)
    return unless valid_key?(key)
      record = @keys[key]
  end

  alias_method :gets, :get 

  private

  def valid_key?(key)
    return false unless @keys[key]

    exptime = @keys[key][:exptime]

    if exptime.to_i != 0 && exptime < Time.now
      @keys.delete(key)
      return false
    end

    true
  end 

  private 

  def set_token(key)
    @keys[key][:cas_token] = @last_token + 1
    @last_token = @last_token + 1
  end

  def set_values(type, key, **data)
    if valid_key?(key)
      @keys[key][:bytes] = @keys[key][:bytes].to_i + data[:bytes].to_i
      @keys[key][:value] = @keys[key][:value].send(type, data[:value])
    end
  end

  def set_exptime(key, **data)
    exptime = data[:exptime].to_i
    if exptime > 0
      @keys[key][:exptime] = Time.now + exptime
    elsif exptime == 0
      @keys[key][:exptime] = 0
    else
      @keys.delete(key)
    end
  end

end

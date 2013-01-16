module ImprovedCacheHelper
  CACHE_VERSION = 2

  def my_cache(name = {}, options = nil, &block)
    if controller.perform_caching and false
      safe_concat(fragment_for(cache_key(name), options, &block))
    else
      yield
    end

    nil
  end

private
  def cache_key(key)
    "#{retrieve_cache_key(key)}:#{CACHE_VERSION}"
  end

  def retrieve_cache_key(key)
    case
      when key.respond_to?(:cache_key) then key.cache_key
      when key.is_a?(Array)            then key.map { |element| retrieve_cache_key(element) }.to_param
      else                                  key.to_param
    end.to_s
  end

  # TODO: Create an object that has caching read/write on it
  def fragment_for(name = {}, options = nil, &block) #:nodoc:
    if Rails.cache.exist?(name)
      Rails.cache.read(name)
    else
      # VIEW TODO: Make #capture usable outside of ERB
      # This dance is needed because Builder can't use capture
      pos = output_buffer.length
      yield
      output_safe = output_buffer.html_safe?
      fragment = output_buffer.slice!(pos..-1)
      if output_safe
        self.output_buffer = output_buffer.class.new(output_buffer)
      end
      Rails.cache.write(name, fragment)
      fragment
    end
  end
end
# frozen_string_literal: false

# :stopdoc:
class Hash
  # remove any other version of #to_html_attributes
  undef_method :to_html_attributes if method_defined?(:to_html_attributes)

  # Converts a hash into HTML attribute string representation.
  #
  # @param empties [Boolean, nil] If provided and not nil, will exclude keys with blank values
  #
  # @return [String] HTML attribute string with keys sorted alphabetically
  #
  # @example
  #   {class: 'button', id: 'submit'}.to_html_attributes #=> 'class="button" id="submit"'
  #   {name: nil, id: 'test'}.to_html_attributes(true) #=> 'id="test"'
  #
  def to_html_attributes(empties = nil)
    hash = dup
    hash.reject! { |_k, v| v.blank? } unless empties.nil?
    out = ''
    hash.keys.sort.each do |key| # NB!! sorting output order of attributes alphabetically
      val = hash[key].is_a?(Array) ? hash[key].join('_') : hash[key].to_s
      out << "#{key}=\"#{val}\" "
    end
    out.strip
  end

  unless method_defined?(:reverse_merge)
    # Performs a non-destructive reverse merge with another hash
    # This is particularly useful for initializing an options hash with default values.
    #
    # @param other_hash [Hash] The hash to merge into
    #
    # @return [Hash] A new hash with other_hash merged into self
    #
    # @example A basic example
    #
    #   options = options.reverse_merge(size: 25, velocity: 10)
    #
    # is equivalent to
    #
    #   options = { size: 25, velocity: 10 }.merge(options)
    #
    def reverse_merge(other_hash)
      other_hash.merge(self)
    end
  end

  unless method_defined?(:reverse_merge!)
    # Performs a destructive reverse merge with another hash.
    # Modifies the original hash by merging in the provided hash while keeping existing values.
    #
    # @param other_hash [Hash] The hash to merge into self
    #
    # @return [Hash] The modified hash with other_hash merged in
    #
    # @example
    #   options = { size: 10 }
    #   options.reverse_merge!(size: 25, velocity: 10)
    #   # => { size: 10, velocity: 10 }
    #
    def reverse_merge!(other_hash)
      # right wins if there is no left
      merge!(other_hash) { |_key, left, _right| left }
    end
    alias reverse_update reverse_merge!
  end
end
# :startdoc:

# frozen_string_literal: false

# :stopdoc:
class Hash
  # remove any other version of #to_html_attributes
  undef_method :to_html_attributes if method_defined?(:to_html_attributes)

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
    # Merges the caller into +other_hash+. For example,
    #
    #   options = options.reverse_merge(size: 25, velocity: 10)
    #
    # is equivalent to
    #
    #   options = { size: 25, velocity: 10 }.merge(options)
    #
    # This is particularly useful for initializing an options hash
    # with default values.
    def reverse_merge(other_hash)
      other_hash.merge(self)
    end
  end

  unless method_defined?(:reverse_merge!)
    # Destructive +reverse_merge+.
    def reverse_merge!(other_hash)
      # right wins if there is no left
      merge!(other_hash) { |_key, left, _right| left }
    end
    alias reverse_update reverse_merge!
  end
end
# :startdoc:

# frozen_string_literal: true

# reopening Object class
class Object
  # Checks if an object is blank or not.
  # An object is blank if it does not respond to empty? or if it returns false on calling empty?.
  # If it does not respond to empty?, then it will check if the object is truthy.
  #
  # This simplifies `!address || address.empty?` to `address.blank?`
  #
  # @return [true, false] false if object responds to empty? and
  #          empty? returns false, true otherwise
  #
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  # Returns true if the object is not blank.
  # An object is considered not blank if it has meaningful content.
  #
  # @return [true, false] true if object is not blank, false otherwise
  #
  def present?
    !blank?
  end

  # Returns self if the object is present, otherwise returns nil.
  #
  # @return [Object, nil] self if present?, nil otherwise
  #
  # `object.presence` is equivalent to `object.present? ? object : nil`
  #
  # For example, something like
  #
  #   state   = params[:state]   if params[:state].present?
  #   country = params[:country] if params[:country].present?
  #   region  = state || country || 'US'
  #
  # becomes
  #
  #   region = params[:state].presence || params[:country].presence || 'US'
  #
  def presence
    self if present?
  end
end

# reopening NilClass class
class NilClass
  # +nil+ is blank:
  #
  #   nil.blank? # => true
  #
  # @return [true]
  def blank?
    true
  end
end

# reopening FalseClass class
class FalseClass
  # +false+ is blank:
  #
  #   false.blank? # => true
  #
  # @return [true]
  def blank?
    true
  end
end

# reopening TrueClass class
class TrueClass
  # +true+ is not blank:
  #
  #   true.blank? # => false
  #
  # @return [false]
  def blank?
    false
  end
end

# reopening Array class
class Array
  # An array is blank if it's empty:
  #
  #   [].blank?      # => true
  #   [1,2,3].blank? # => false
  #
  # @return [true, false]
  alias blank? empty?
end

# reopening Hash class
class Hash
  # A hash is blank if it's empty:
  #
  #   {}.blank?                # => true
  #   { key: 'value' }.blank?  # => false
  #
  # @return [true, false]
  alias blank? empty?
end

# reopening String class
class String
  BLANK_RE = /\A[[:space:]]*\z/

  # Returns true if the string consists entirely of whitespace characters
  #
  # @return [true, false] true if string is empty or only whitespace, false otherwise
  #
  # @example A basic example
  #
  #   ''.blank?       # => true
  #   '   '.blank?    # => true
  #   "\t\n\r".blank? # => true
  #   ' blah '.blank? # => false
  #
  # @example Unicode whitespace support
  #
  #   "\u00a0".blank? # => true
  #
  def blank?
    BLANK_RE === self
  end
end

# reopening Numeric class
class Numeric # :nodoc:
  # No numeric value is blank:
  #
  # @return [false]
  #
  # @example A basic example
  #
  #   1.blank? # => false
  #   0.blank? # => false
  #
  def blank?
    false
  end
end

# reopening Time class
class Time # :nodoc:
  # No Time is blank
  #
  # @return [false]
  #
  # @example A basic example
  #
  #   Time.now.blank? # => false
  #
  def blank?
    false
  end
end

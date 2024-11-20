# frozen_string_literal: false

# The inflector extension adds inflection instance methods to String, which allows the easy
# transformation of words from singular to plural, class names to table names, modularized class
# names to ones without, and class names to foreign keys.  It exists for
# backwards compatibility to legacy Sequel code.
#
# To load the extension:
class String
  # This module acts as a singleton returned/yielded by String.inflections,
  # which is used to override or specify additional inflection rules. Examples:
  #
  #   String.inflections do |inflect|
  #     inflect.plural /^(ox)$/i, '\1\2en'
  #     inflect.singular /^(ox)en/i, '\1'
  #
  #     inflect.irregular 'octopus', 'octopi'
  #
  #     inflect.uncountable "equipment"
  #   end
  #
  # New rules are added at the top. So in the example above, the irregular rule for octopus will
  # now be the first of the pluralization and singularization rules that is runs. This guarantees
  # that your rules run before any of the rules that may already have been loaded.
  #
  module Inflections
    # Array to store plural inflection rules
    @plurals   = []
    # Array to store singular inflection rules
    @singulars = []
    # Array to store words that are the same in singular and plural forms
    @uncountables = []

    # Proc that is instance evaled to create the default inflections for both the
    # model inflector and the inflector extension.
    # rubocop:disable Metrics/BlockLength
    DEFAULT_INFLECTIONS_PROC = proc do
      plural(/$/, 's')
      plural(/s$/i, 's')
      plural(/(alias|(?:stat|octop|vir|b)us)$/i, '\1es')
      plural(/(buffal|tomat)o$/i, '\1oes')
      plural(/([ti])um$/i, '\1a')
      plural(/sis$/i, 'ses')
      plural(/(?:([^f])fe|([lr])f)$/i, '\1\2ves')
      plural(/(hive)$/i, '\1s')
      plural(/([^aeiouy]|qu)y$/i, '\1ies')
      plural(/(x|ch|ss|sh)$/i, '\1es')
      plural(/(matr|vert|ind)ix|ex$/i, '\1ices')
      plural(/([m|l])ouse$/i, '\1ice')

      singular(/s$/i, '')
      singular(/([ti])a$/i, '\1um')
      singular(/(analy|ba|cri|diagno|parenthe|progno|synop|the)ses$/i, '\1sis')
      singular(/([^f])ves$/i, '\1fe')
      singular(/([h|t]ive)s$/i, '\1')
      singular(/([lr])ves$/i, '\1f')
      singular(/([^aeiouy]|qu)ies$/i, '\1y')
      singular(/(m)ovies$/i, '\1ovie')
      singular(/(x|ch|ss|sh)es$/i, '\1')
      singular(/([m|l])ice$/i, '\1ouse')
      singular(/buses$/i, 'bus')
      singular(/oes$/i, 'o')
      singular(/shoes$/i, 'shoe')
      singular(/(alias|(?:stat|octop|vir|b)us)es$/i, '\1')
      singular(/(vert|ind)ices$/i, '\1ex')
      singular(/matrices$/i, 'matrix')

      irregular('person', 'people')
      irregular('man', 'men')
      irregular('child', 'children')
      irregular('sex', 'sexes')
      irregular('move', 'moves')
      irregular('quiz', 'quizzes')
      irregular('testis', 'testes')

      uncountable(%w[equipment information rice money species series fish sheep news])
    end
    # rubocop:enable Metrics/BlockLength

    class << self
      # An Array that stores the pluralization rules.
      # Each rule is a 2-element array containing:
      # - A regular expression pattern for matching words to pluralize
      # - A substitution pattern (e.g. '\1es') for transforming the match into plural form
      # Rules are processed in reverse order, so newer rules take precedence.
      attr_reader :plurals

      # An Array that stores the singularization rules.
      # Each rule is a 2-element array containing:
      # - A regular expression pattern for matching plural words
      # - A substitution pattern (e.g. '\1y') for transforming the match into singular form
      # Rules are processed in reverse order, so newer rules take precedence.
      attr_reader :singulars

      # An Array of uncountable word strings that should not be inflected.
      # These words have the same form in both singular and plural.
      # Examples: 'fish', 'money', 'species'
      attr_reader :uncountables
    end

    # Clear inflection rules in a given scope.
    # If scope is not specified, all inflection rules will be cleared.
    # Passing :plurals, :singulars, or :uncountables will clear only that specific type of rule.
    #
    # @param scope [Symbol] The scope of rules to clear. Can be :all (default),
    #   :plurals, :singulars, or :uncountables
    # @return [Array] An empty array
    #
    # @example Clear all inflection rules
    #   String.inflections.clear
    #
    # @example Clear only plural rules
    #   String.inflections.clear(:plurals)
    #
    def self.clear(scope = :all)
      case scope
      when :all
        @plurals      = []
        @singulars    = []
        @uncountables = []
      else
        instance_variable_set(:"@#{scope}", [])
      end
    end

    # Specifies a new irregular inflection rule that transforms between singular and plural forms.
    # This method creates rules for both pluralization and singularization simultaneously.
    # Unlike regular inflection rules, this only works with literal strings, not regexp.
    #
    # @param singular [String] The singular form of the word
    # @param plural [String] The plural form of the word
    #
    # @example
    #   irregular('person', 'people')  # Creates rules to transform person <-> people
    #   irregular('child', 'children') # Creates rules to transform child <-> children
    #
    def self.irregular(singular, plural)
      plural(Regexp.new("(#{singular[0, 1]})#{singular[1..-1]}$", 'i'), '\1' + plural[1..-1])
      singular(Regexp.new("(#{plural[0, 1]})#{plural[1..-1]}$", 'i'), '\1' + singular[1..-1])
    end

    # Specifies a new pluralization rule to transform singular words into plural forms.
    # Adds the rule to the beginning of the rules array so it takes precedence over existing rules.
    #
    # @param rule [Regexp, String] Pattern to match words that should be pluralized
    # @param replacement [String] Template for constructing the plural form, can reference
    #   captured groups from the rule pattern using \1, \2 etc.
    # @return [Array] The updated array of plural rules
    #
    # @example Add rule to pluralize words ending in 'y'
    #   plural(/([^aeiou])y$/i, '\1ies') # changes 'fly' to 'flies'
    #
    def self.plural(rule, replacement)
      @plurals.insert(0, [rule, replacement])
    end

    # Specifies a new singularization rule to transform plural words into singular forms.
    # Adds the rule to the beginning of the rules array so it takes precedence over existing rules.
    #
    # @param rule [Regexp, String] Pattern to match words that should be singularized
    # @param replacement [String] Template for constructing the singular form, can reference
    #   captured groups from the rule pattern using \1, \2 etc.
    #
    # @return [Array] The updated array of singular rules
    #
    # @example Add rule to singularize words ending in 'ies'
    #   singular(/([^aeiou])ies$/i, '\1y') # changes 'flies' to 'fly'
    #
    def self.singular(rule, replacement)
      @singulars.insert(0, [rule, replacement])
    end

    # Adds words that have the same singular and plural form to the uncountables list.
    # These words will be skipped by the inflector and returned unchanged.
    #
    # @param words [Array<String>] One or more words to mark as uncountable
    # @return [Array] The flattened array of all uncountable words
    #
    # @example Add a single uncountable word
    #   uncountable "fish"
    #
    # @example Add multiple uncountable words
    #   uncountable "rice", "equipment"
    #
    # @example Add an array of uncountable words
    #   uncountable %w(sheep species)
    #
    def self.uncountable(*words)
      (@uncountables << words).flatten!
    end

    # Execute the default inflection rules defined in DEFAULT_INFLECTIONS_PROC
    # This sets up the basic plural/singular transformations and irregular/uncountable words
    # that the inflector will use by default
    instance_exec(&DEFAULT_INFLECTIONS_PROC)
  end

  # Provides access to the Inflections module for defining custom inflection rules.
  # If a block is given, yields the Inflections module to the block.
  # Always returns the Inflections module.
  #
  # @yield [Inflections] The Inflections module if a block is given
  #
  # @return [Inflections] The Inflections module
  #
  # @example Define custom inflection rules
  #   String.inflections do |inflect|
  #     inflect.plural /^(ox)$/i, '\1\2en'
  #     inflect.singular /^(ox)en/i, '\1'
  #   end
  #
  def self.inflections
    yield Inflections if defined?(yield)
    Inflections
  end

  # Converts the string to CamelCase format.
  # - Replaces forward slashes with double colons (e.g. 'foo/bar' -> 'Foo::Bar')
  # - Converts underscores to camelized format (e.g. 'foo_bar' -> 'FooBar')
  #
  # @param first_letter_in_uppercase [Symbol] Whether first letter should be
  #    uppercase (:upper) or lowercase (:lower)
  #
  # @return [String] The camelized string
  #
  # @example Convert to UpperCamelCase
  #   "active_record".camelize #=> "ActiveRecord"
  #
  # @example Convert to lowerCamelCase
  #   "active_record".camelize(:lower) #=> "activeRecord"
  #
  # @example Convert path to namespace
  #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
  #
  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(%r{/(.?)})   { |x| "::#{x[-1..-1].upcase unless x == '/'}" }
        .gsub(/(^|_)(.)/) { |x| x[-1..-1].upcase }
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end
  alias camelcase camelize

  # Converts a string into a class name by removing any non-final period and subsequent characters,
  # converting to singular form, and camelizing.
  # Commonly used to obtain class name from table or file names.
  #
  # @return [String] A camelized singular form suitable for a class name
  #
  # @example Convert database table name to class name
  #   "egg_and_hams".classify #=> "EggAndHam"
  #
  # @example Remove schema prefix
  #   "schema.post".classify #=> "Post"
  #
  # @example Basic conversion
  #   "post".classify #=> "Post"
  #
  def classify
    sub(/.*\./, '').singularize.camelize
  end

  # Finds and returns a Ruby constant from a string name.
  # The string must be a valid constant name in CamelCase format.
  # Can handle namespaced constants using double colons (::).
  # Raises NameError if the constant name is invalid or not defined.
  #
  # @return [Object] The Ruby constant corresponding to the string name
  #
  # @raise [NameError] If string is not a valid constant name or constant is not defined
  #
  # @example Get Module class
  #   "Module".constantize #=> Module
  #
  # @example Get namespaced constant
  #   "ActiveRecord::Base".constantize #=> ActiveRecord::Base
  #
  # @example Invalid constant name
  #   "invalid_name".constantize #=> NameError: invalid_name is not a valid constant name!
  #
  def constantize
    unless m = /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/.match(self)
      raise(NameError, "#{inspect} is not a valid constant name!") 
    end
    Object.module_eval("::#{m[1]}", __FILE__, __LINE__)
  end

  # Replaces underscores (_) in a string with dashes (-).
  # A helper method commonly used for URL slugs and CSS class names.
  #
  # @return [String] The string with underscores replaced by dashes
  #
  # @example
  #   "hello_world".dasherize #=> "hello-world"
  #   "foo_bar_baz".dasherize #=> "foo-bar-baz"
  #
  def dasherize
    tr('_', '-')
  end

  # Removes the module part from a fully-qualified Ruby constant name,
  # returning just the rightmost portion after the last double colon (::).
  #
  # @return [String] The final constant name without any module namespacing
  #
  # @example Remove module namespace from fully-qualified name
  #   "ActiveRecord::Base::Table".demodulize #=> "Table"
  #
  # @example No change when no modules present
  #   "String".demodulize #=> "String"
  #
  def demodulize
    gsub(/^.*::/, '')
  end

  # Creates a foreign key name from a class name by removing any module namespacing,
  # underscoring the remaining name, and appending 'id'. The underscore before 'id'
  # is optional.
  #
  # @param use_underscore [Boolean] Whether to include an underscore before 'id'
  #
  # @return [String] The foreign key name
  #
  # @example Basic usage
  #   "Message".foreign_key #=> "message_id"
  #
  # @example Without underscore
  #   "Message".foreign_key(use_underscore: false) #=> "messageid"
  #
  # @example With namespaced class
  #   "Admin::Post".foreign_key #=> "post_id"
  #
  def foreign_key(use_underscore: true)
    "#{demodulize.underscore}#{"_" if use_underscore}id"
  end

  # Converts a string into a more human-readable format by:
  # - Removing any trailing '_id'
  # - Converting underscores to spaces
  # - Capitalizing the first letter
  #
  # @return [String] A human-friendly version of the string
  #
  # @example Convert a database column name
  #   "employee_salary".humanize #=> "Employee salary"
  #
  # @example Remove ID suffix
  #   "user_id".humanize #=> "User"
  #
  # @example Basic conversion
  #   "hello_world".humanize #=> "Hello world"
  #
  def humanize
    gsub(/_id$/, '').tr('_', ' ').capitalize
  end

  # Transforms a word into its plural form according to standard English language rules
  # and any custom rules defined through String.inflections.
  #
  # If the word is in the uncountable list (e.g. "sheep", "fish"), returns it unchanged.
  # Otherwise applies plural transformation rules in order until one matches.
  #
  # @return [String] The plural form of the word
  #
  # @example Basic pluralization
  #   "post".pluralize #=> "posts"
  #   "octopus".pluralize #=> "octopi"
  #
  # @example Uncountable words
  #   "fish".pluralize #=> "fish"
  #
  # @example Complex phrases
  #   "the blue mailman".pluralize #=> "the blue mailmen"
  #   "CamelOctopus".pluralize #=> "CamelOctopi"
  #
  def pluralize
    result = dup
    unless Inflections.uncountables.include?(downcase)
      Inflections.plurals.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
    end
    result
  end

  # Transforms a word into its singular form according to standard English language rules
  # and any custom rules defined through String.inflections.
  #
  # If the word is in the uncountable list (e.g. "sheep", "fish"), returns it unchanged.
  # Otherwise applies singular transformation rules in order until one matches.
  #
  # @return [String] The singular form of the word
  #
  # @example Basic singularization
  #   "posts".singularize #=> "post"
  #   "matrices".singularize #=> "matrix"
  #
  # @example Uncountable words
  #   "fish".singularize #=> "fish"
  #
  # @example Complex phrases
  #   "the blue mailmen".singularize #=> "the blue mailman"
  #   "CamelOctopi".singularize #=> "CamelOctopus"
  #
  def singularize
    result = dup
    unless Inflections.uncountables.include?(downcase)
      Inflections.singulars.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
    end
    result
  end

  # Converts a class name or CamelCase word to a suitable database table name
  # by underscoring and pluralizing it. Namespaces are converted to paths.
  # Used to derive table names from model class names.
  #
  # @return [String] The table name (underscored, pluralized form)
  #
  # @example Convert class name to table name
  #   "RawScaledScorer".tableize #=> "raw_scaled_scorers"
  #
  # @example Handle namespaces
  #   "Admin::Post".tableize #=> "admin/posts"
  #
  # @example Basic conversion
  #   "fancyCategory".tableize #=> "fancy_categories"
  #
  def tableize
    underscore.pluralize
  end

  # Converts a string into a more human-readable title format by:
  # - Converting underscores and dashes to spaces
  # - Capitalizing each word
  # - Applying human-friendly formatting
  #
  # titleize is also aliased as as titlecase
  #
  # @return [String] A titleized version of the string
  #
  # @example Convert basic string to title
  #   "hello_world".titleize #=> "Hello World"
  #
  # @example Convert with special characters
  #   "x-men: the last stand".titleize #=> "X Men: The Last Stand"
  #
  # @example Convert camelCase to title
  #   "camelCase".titleize #=> "Camel Case"
  #
  def titleize
    underscore.humanize.gsub(/\b([a-z])/) { |x| x[-1..].upcase }
  end
  alias titlecase titleize

  # Converts a CamelCase or camelCase string into an underscored format.
  # - Replaces '::' with '/' for namespace/path conversion
  # - Adds underscores between words including:
  #   - Between runs of capital letters: 'ABC' -> 'a_b_c'
  #   - Before first lowercase letter after capitals: 'HTMLParser' -> 'html_parser'
  #   - Before capitals after lowercase/numbers: 'fooBar' -> 'foo_bar'
  # - Converts all dashes to underscores
  # - Converts everything to lowercase
  #
  # @return [String] The underscored version of the string
  #
  # @example Convert camelCase
  #   "camelCase".underscore #=> "camel_case"
  #   "ActiveRecord".underscore #=> "active_record"
  #
  # @example Convert namespace
  #   "ActiveRecord::Errors".underscore #=> 'active_record/errors'
  #
  # @example Convert complex CamelCase
  #   "HTMLParser".underscore #=> "html_parser"
  #
  def underscore
    gsub('::', '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
  end
end

# Ripped from the Sequel gem by Jeremy Evans
# https://github.com/jeremyevans/sequel/blob/master/lib/sequel/extensions/inflector.rb
#
#
# Copyright (c) 2007-2008 Sharon Rosner
# Copyright (c) 2008-2015 Jeremy Evans
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

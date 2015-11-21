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
  module Inflections
    @plurals   = []
    @singulars = []
    @uncountables = []
    
    # Proc that is instance evaled to create the default inflections for both the
    # model inflector and the inflector extension.
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

      uncountable(%w(equipment information rice money species series fish sheep news))
    end
    
    
    class << self
      # Array of 2 element arrays, first containing a regex, and the second containing a 
      # substitution pattern, used for plurization.
      attr_reader :plurals

      # Array of 2 element arrays, first containing a regex, and the second containing a 
      # substitution pattern, used for singularization.
      attr_reader :singulars

      # Array of strings for words were the singular form is the same as the plural form
      attr_reader :uncountables
    end

    # Clears the loaded inflections within a given scope (default is :all). Give the scope as a 
    # symbol of the inflection type, the options are: :plurals, :singulars, :uncountables
    #
    # Examples:
    #   clear :all
    #   clear :plurals
    def self.clear(scope = :all)
      case scope
      when :all
        @plurals      = []
        @singulars    = []
        @uncountables = []
      else
        instance_variable_set("@#{scope}", [])
      end
    end

    # Specifies a new irregular that applies to both pluralization and singularization at the same 
    # time. This can only be used for strings, not regular expressions. You simply pass the 
    # irregular in singular and plural form.
    #
    # Examples:
    #   irregular 'octopus', 'octopi'
    #   irregular 'person', 'people'
    def self.irregular(singular, plural)
      plural(Regexp.new("(#{singular[0, 1]})#{singular[1..-1]}$", 'i'), '\1' + plural[1..-1])
      singular(Regexp.new("(#{plural[0, 1]})#{plural[1..-1]}$", 'i'), '\1' + singular[1..-1])
    end

    # Specifies a new pluralization rule and its replacement. The rule can either be a string or a 
    # regular expression. The replacement should always be a string that may include references to 
    # the matched data from the rule.
    #
    # Example:
    #   plural(/(x|ch|ss|sh)$/i, '\1es')
    def self.plural(rule, replacement)
      @plurals.insert(0, [rule, replacement])
    end

    # Specifies a new singularization rule and its replacement. The rule can either be a string or 
    # a regular expression. The replacement should always be a string that may include references 
    # to the matched data from the rule.
    #
    # Example:
    #   singular(/([^aeiouy]|qu)ies$/i, '\1y') 
    def self.singular(rule, replacement)
      @singulars.insert(0, [rule, replacement])
    end

    # Add uncountable words that shouldn't be attempted inflected.
    #
    # Examples:
    #   uncountable "money"
    #   uncountable "money", "information"
    #   uncountable %w( money information rice )
    def self.uncountable(*words)
      (@uncountables << words).flatten!
    end

    # Sequel.require('default_inflections', 'model')
    # instance_eval(&Sequel::DEFAULT_INFLECTIONS_PROC)
    # Sequel.require('default_inflections', 'model')
    instance_eval(&DEFAULT_INFLECTIONS_PROC)
  end

  # Yield the Inflections module if a block is given, and return
  # the Inflections module.
  def self.inflections
    yield Inflections if block_given?
    Inflections
  end

  # By default, camelize converts the string to UpperCamelCase. If the argument to camelize
  # is set to :lower then camelize produces lowerCamelCase.
  #
  # camelize will also convert '/' to '::' which is useful for converting paths to namespaces
  #
  # Examples
  #   "active_record".camelize #=> "ActiveRecord"
  #   "active_record".camelize(:lower) #=> "activeRecord"
  #   "active_record/errors".camelize #=> "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) #=> "activeRecord::Errors"
  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(%r{/(.?)})   { |x| "::#{x[-1..-1].upcase unless x == '/'}" }
        .gsub(/(^|_)(.)/) { |x| x[-1..-1].upcase }
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end
  alias_method :camelcase, :camelize

  # Singularizes and camelizes the string.  Also strips out all characters preceding
  # and including a period (".").
  #
  # Examples
  #   "egg_and_hams".classify #=> "EggAndHam"
  #   "post".classify #=> "Post"
  #   "schema.post".classify #=> "Post"
  def classify
    sub(/.*\./, '').singularize.camelize
  end

  # Constantize tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.
  #
  # Examples
  #   "Module".constantize #=> Module
  #   "Class".constantize #=> Class
  def constantize
    unless m = /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/.match(self)
      raise(NameError, "#{inspect} is not a valid constant name!") 
    end
    Object.module_eval("::#{m[1]}", __FILE__, __LINE__)
  end

  # Replaces underscores with dashes in the string.
  #
  # Example
  #   "puni_puni".dasherize #=> "puni-puni"
  def dasherize
    tr('_', '-')
  end

  # Removes the module part from the expression in the string
  #
  # Examples
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize #=> "Inflections"
  #   "Inflections".demodulize #=> "Inflections"
  def demodulize
    gsub(/^.*::/, '')
  end

  # Creates a foreign key name from a class name.
  # +use_underscore+ sets whether the method should put '_' between the name and 'id'.
  #
  # Examples
  #   "Message".foreign_key #=> "message_id"
  #   "Message".foreign_key(false) #=> "messageid"
  #   "Admin::Post".foreign_key #=> "post_id"
  def foreign_key(use_underscore = true)
    "#{demodulize.underscore}#{'_' if use_underscore}id"
  end

  # Capitalizes the first word and turns underscores into spaces and strips _id.
  # Like titleize, this is meant for creating pretty output.
  #
  # Examples
  #   "employee_salary" #=> "Employee salary"
  #   "author_id" #=> "Author"
  def humanize
    gsub(/_id$/, '').tr('_', ' ').capitalize
  end

  # Returns the plural form of the word in the string.
  #
  # Examples
  #   "post".pluralize #=> "posts"
  #   "octopus".pluralize #=> "octopi"
  #   "sheep".pluralize #=> "sheep"
  #   "words".pluralize #=> "words"
  #   "the blue mailman".pluralize #=> "the blue mailmen"
  #   "CamelOctopus".pluralize #=> "CamelOctopi"
  def pluralize
    result = dup
    unless Inflections.uncountables.include?(downcase)
      Inflections.plurals.each { |(rule, replacement)| break if result.gsub!(rule, replacement) } 
    end
    result
  end

  # The reverse of pluralize, returns the singular form of a word in a string.
  #
  # Examples
  #   "posts".singularize #=> "post"
  #   "octopi".singularize #=> "octopus"
  #   "sheep".singluarize #=> "sheep"
  #   "word".singluarize #=> "word"
  #   "the blue mailmen".singularize #=> "the blue mailman"
  #   "CamelOctopi".singularize #=> "CamelOctopus"
  def singularize
    result = dup
    unless Inflections.uncountables.include?(downcase)
      Inflections.singulars.each { |(rule, replacement)| break if result.gsub!(rule, replacement) } 
    end
    result
  end

  # Underscores and pluralizes the string.
  #
  # Examples
  #   "RawScaledScorer".tableize #=> "raw_scaled_scorers"
  #   "egg_and_ham".tableize #=> "egg_and_hams"
  #   "fancyCategory".tableize #=> "fancy_categories"
  def tableize
    underscore.pluralize
  end

  # Capitalizes all the words and replaces some characters in the string to create
  # a nicer looking title. Titleize is meant for creating pretty output.
  #
  # titleize is also aliased as as titlecase
  #
  # Examples
  #   "man from the boondocks".titleize #=> "Man From The Boondocks"
  #   "x-men: the last stand".titleize #=> "X Men: The Last Stand"
  def titleize
    underscore.humanize.gsub(/\b([a-z])/) { |x| x[-1..-1].upcase }
  end
  alias_method :titlecase, :titleize

  # The reverse of camelize. Makes an underscored form from the expression in the string.
  # Also changes '::' to '/' to convert namespaces to paths.
  #
  # Examples
  #   "ActiveRecord".underscore #=> "active_record"
  #   "ActiveRecord::Errors".underscore #=> active_record/errors
  def underscore
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
  end
end


# Ripped from the Sequel gem by Jeremy Evans
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

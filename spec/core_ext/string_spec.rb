require_relative '../spec_helper'


class CoreExtStringSpec < Minitest::Spec
  
  describe 'CoreExt' do
    
    describe '"core_ext/hash"' do
      require_relative '../../lib/core_ext/string'
      
      describe String do
    
        it "#camelize and #camelcase should transform the word to CamelCase" do
          _("egg_and_hams".camelize).must_equal "EggAndHams"
          _("egg_and_hams".camelize(false)).must_equal "eggAndHams"
          _("post".camelize).must_equal "Post"
          _("post".camelcase).must_equal "Post"
        end

        it "#constantize should eval the string to get a constant" do
          _("String".constantize).must_equal String
          _("String::Inflections".constantize).must_equal String::Inflections
          _(proc{"BKSDDF".constantize}).must_raise NameError
          _(proc{"++A++".constantize}).must_raise NameError
        end
  
        it "#dasherize should transform underscores to dashes" do
          _("egg_and_hams".dasherize).must_equal "egg-and-hams"
          _("post".dasherize).must_equal "post"
        end
  
        it "#demodulize should remove any preceding modules" do
          _("String::Inflections::Blah".demodulize).must_equal "Blah"
          _("String::Inflections".demodulize).must_equal "Inflections"
          _("String".demodulize).must_equal "String"
        end
  
        it "#humanize should remove _i, transform underscore to spaces, and capitalize" do
          _("egg_and_hams".humanize).must_equal "Egg and hams"
          _("post".humanize).must_equal "Post"
          _("post_id".humanize).must_equal "Post"
        end
  
        it "#titleize and #titlecase should underscore, humanize, and capitalize all words" do
          _("egg-and: hams".titleize).must_equal "Egg And: Hams"
          _("post".titleize).must_equal "Post"
          _("post".titlecase).must_equal "Post"
        end
  
        it "#underscore should add underscores between CamelCased words, change :: to / and - to _, and downcase" do
          _("EggAndHams".underscore).must_equal "egg_and_hams"
          _("EGGAndHams".underscore).must_equal "egg_and_hams"
          _("Egg::And::Hams".underscore).must_equal "egg/and/hams"
          _("post".underscore).must_equal "post"
          _("post-id".underscore).must_equal "post_id"
        end

        it "#pluralize should transform words from singular to plural" do
          _("post".pluralize).must_equal "posts"
          _("octopus".pluralize).must_equal"octopuses"
          _("the blue mailman".pluralize).must_equal "the blue mailmen"
          _("CamelOctopus".pluralize).must_equal "CamelOctopuses"
        end
  
        it "#singularize should transform words from plural to singular" do
          _("posts".singularize).must_equal "post"
          _("octopuses".singularize).must_equal "octopus"
          _("the blue mailmen".singularize).must_equal "the blue mailman"
          _("CamelOctopuses".singularize).must_equal "CamelOctopus"
        end
  
        it "#tableize should transform class names to table names" do
          _("RawScaledScorer".tableize).must_equal "raw_scaled_scorers"
          _("egg_and_ham".tableize).must_equal "egg_and_hams"
          _("fancyCategory".tableize).must_equal "fancy_categories"
        end
  
        it "#classify should tranform table names to class names" do
          _("egg_and_hams".classify).must_equal "EggAndHam"
          _("post".classify).must_equal "Post"
        end
  
        it "#foreign_key should create a foreign key name from a class name" do
          _("Message".foreign_key).must_equal "message_id"
          _("Message".foreign_key(false)).must_equal "messageid"
          _("Admin::Post".foreign_key).must_equal "post_id"
        end
      end

      describe String::Inflections do
    
        before do
          @plurals, @singulars, @uncountables = String.inflections.plurals.dup, String.inflections.singulars.dup, String.inflections.uncountables.dup
        end
    
        after do
          String.inflections.plurals.replace(@plurals)
          String.inflections.singulars.replace(@singulars)
          String.inflections.uncountables.replace(@uncountables)
        end

        it "should be possible to clear the list of singulars, plurals, and uncountables" do
          String.inflections.clear(:plurals)
          _(String.inflections.plurals).must_equal []
          String.inflections.plural('blah', 'blahs')
          String.inflections.clear
          _(String.inflections.plurals).must_equal []
          _(String.inflections.singulars).must_equal []
          _(String.inflections.uncountables).must_equal []
        end

        it "should be able to specify new inflection rules" do
          String.inflections do |i|
            i.plural(/xx$/i, 'xxx')
            i.singular(/ttt$/i, 'tt')
            i.irregular('yy', 'yyy')
            i.uncountable(%w'zz')
          end
          _('roxx'.pluralize).must_equal 'roxxx'
          _('rottt'.singularize).must_equal 'rott'
          _('yy'.pluralize).must_equal 'yyy'
          _('yyy'.singularize).must_equal 'yy'
          _('zz'.pluralize).must_equal 'zz'
          _('zz'.singularize).must_equal 'zz'
        end

        it "should be yielded and returned by String.inflections" do
          _(String.inflections{|i| _(i).must_equal String::Inflections}).must_equal String::Inflections
        end
    
      end

      describe 'Default inflections' do
    
        it "should support the default inflection rules" do
          {
            :test        => :tests,
            :ax          => :axes,
            :testis      => :testes,
            :octopus     => :octopuses,
            :virus       => :viruses,
            :alias       => :aliases,
            :status      => :statuses,
            :bus         => :buses,
            :buffalo     => :buffaloes,
            :tomato      => :tomatoes,
            :datum       => :data,
            :bacterium   => :bacteria,
            :analysis    => :analyses,
            :basis       => :bases,
            :diagnosis   => :diagnoses,
            :parenthesis => :parentheses,
            :prognosis   => :prognoses,
            :synopsis    => :synopses,
            :thesis      => :theses,
            :wife        => :wives,
            :giraffe     => :giraffes,
            :self        => :selves,
            :dwarf       => :dwarves,
            :hive        => :hives,
            :fly         => :flies,
            :buy         => :buys,
            :soliloquy   => :soliloquies,
            :day         => :days,
            :attorney    => :attorneys,
            :boy         => :boys,
            :hoax        => :hoaxes,
            :lunch       => :lunches,
            :princess    => :princesses,
            :matrix      => :matrices,
            :vertex      => :vertices,
            :index       => :indices,
            :mouse       => :mice,
            :louse       => :lice,
            :quiz        => :quizzes,
            :motive      => :motives,
            :movie       => :movies,
            :series      => :series,
            :crisis      => :crises,
            :person      => :people,
            :man         => :men,
            :woman       => :women,
            :child       => :children,
            :sex         => :sexes,
            :move        => :moves
          }.each do |k, v|
            _(k.to_s.pluralize).must_equal v.to_s
            _(v.to_s.singularize).must_equal k.to_s
          end
          [:equipment, :information, :rice, :money, :species, :series, :fish, :sheep, :news].each do |a|
            _(a.to_s.pluralize).must_equal a.to_s.singularize
          end
        end
      end

    end
    
  end
  
end
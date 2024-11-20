# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/core_ext/string'

# rubocop:disable Metrics/BlockLength
describe 'CoreExt - core_ext/string' do
  describe String::Inflections do
    before do
      @plurals = String.inflections.plurals.dup
      @singulars = String.inflections.singulars.dup
      @uncountables = String.inflections.uncountables.dup
    end

    after do
      String.inflections.plurals.replace(@plurals)
      String.inflections.singulars.replace(@singulars)
      String.inflections.uncountables.replace(@uncountables)
    end

    it 'should be possible to clear the list of singulars, plurals, and uncountables' do
      String.inflections.clear(:plurals)
      _(String.inflections.plurals).must_equal []
      String.inflections.plural('blah', 'blahs')
      String.inflections.clear
      _(String.inflections.plurals).must_equal []
      _(String.inflections.singulars).must_equal []
      _(String.inflections.uncountables).must_equal []
    end

    it 'should be able to specify new inflection rules' do
      String.inflections do |i|
        i.plural(/xx$/i, 'xxx')
        i.singular(/ttt$/i, 'tt')
        i.irregular('yy', 'yyy')
        i.uncountable(%w[zz])
      end
      _('roxx'.pluralize).must_equal 'roxxx'
      _('rottt'.singularize).must_equal 'rott'
      _('yy'.pluralize).must_equal 'yyy'
      _('yyy'.singularize).must_equal 'yy'
      _('zz'.pluralize).must_equal 'zz'
      _('zz'.singularize).must_equal 'zz'
    end

    it 'should be yielded and returned by String.inflections' do
      _(String.inflections { |i| _(i).must_equal String::Inflections })
        .must_equal String::Inflections
    end

    describe 'Default inflections' do
      it 'should support the default inflection rules' do
        {
          test: :tests,
          ax: :axes,
          testis: :testes,
          octopus: :octopuses,
          virus: :viruses,
          alias: :aliases,
          status: :statuses,
          bus: :buses,
          buffalo: :buffaloes,
          tomato: :tomatoes,
          datum: :data,
          bacterium: :bacteria,
          analysis: :analyses,
          basis: :bases,
          diagnosis: :diagnoses,
          parenthesis: :parentheses,
          prognosis: :prognoses,
          synopsis: :synopses,
          thesis: :theses,
          wife: :wives,
          giraffe: :giraffes,
          self: :selves,
          dwarf: :dwarves,
          hive: :hives,
          fly: :flies,
          buy: :buys,
          soliloquy: :soliloquies,
          day: :days,
          attorney: :attorneys,
          boy: :boys,
          hoax: :hoaxes,
          lunch: :lunches,
          princess: :princesses,
          matrix: :matrices,
          vertex: :vertices,
          index: :indices,
          mouse: :mice,
          louse: :lice,
          quiz: :quizzes,
          motive: :motives,
          movie: :movies,
          series: :series,
          crisis: :crises,
          person: :people,
          man: :men,
          woman: :women,
          child: :children,
          sex: :sexes,
          move: :moves
        }.each do |k, v|
          _(k.to_s.pluralize).must_equal v.to_s
          _(v.to_s.singularize).must_equal k.to_s
        end

        %i[equipment information rice money species series fish sheep news].each do |a|
          _(a.to_s.pluralize).must_equal a.to_s.singularize
        end
      end
    end
  end
  # /String::Inflections
end
# rubocop:enable Metrics/BlockLength

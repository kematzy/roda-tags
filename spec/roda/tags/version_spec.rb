# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'Roda::Tags' do
  describe '::VERSION' do
    it 'should have a version number' do
      _(Roda::Tags::VERSION).wont_be_nil
      _(Roda::Tags::VERSION).must_match(/^\d+\.\d+\.\d+$/)
    end
  end
end

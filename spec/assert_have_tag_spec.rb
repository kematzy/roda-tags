require_relative 'spec_helper'

module Minitest::Assertions
  
  # 
  def assert_returns_error(expected_msg, klass=Minitest::Assertion, &blk)
    e = assert_raises(klass) do
      yield
    end
    assert_equal expected_msg, e.message
  end
  
  # 
  def assert_no_error(&blk)
    e = assert_silent do
      yield
    end
  end
  
end

describe Minitest::Spec do
  
  describe '#assert_have_tag' do
    
    it "should handle nil tag" do
      assert_returns_error('Expected nil to have tag ["br"], but no such tag was found') do 
        assert_have_tag(nil, 'br')
      end
    end
    
    it "should handle empty tag" do
      assert_returns_error('Expected "" to have tag ["br"], but no such tag was found') do 
        assert_have_tag('', 'br')
      end
    end
    
    it "should handle a basic br tag" do
      assert_no_error { assert_have_tag("<br>", 'br') }
    end
    
    it "should handle an incorrectly expected tag" do
      assert_returns_error('Expected "<br>" to have tag ["brr"], but no such tag was found') do 
        assert_have_tag("<br>", 'brr')
      end
    end
    
    it "should handle a basic hr tag with a class attribute" do
      assert_no_error { assert_have_tag('<hr class="divider">', 'hr[class]') }
    end
    
    it "should handle an basic hr tag with a class attribute with an incorrectly expected attribute" do
      assert_returns_error('Expected "<hr class=\"divider\">" to have tag ["hr[classs]"], but no such tag was found') do 
        assert_have_tag('<hr class="divider">', 'hr[classs]')
      end
    end
    
    it "should handle a basic tag with a class attribute" do
      assert_no_error { assert_have_tag('<hr class="divider">', 'hr[class=divider]') }
    end
    
    it "should handle an basic tag with a class attribute with an incorrectly expected attribute" do
      assert_returns_error('Expected "<hr class=\"divider\">" to have tag ["hr[class=divder]"], but no such tag was found') do 
        assert_have_tag('<hr class="divider">', 'hr[class=divder]')
      end
    end
    
    it "should handle a basic div tag with id and class attributes" do
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div#header') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div[id=header]') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div.row') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div[class=row]') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div#header.row') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div[id=header][class=row]') }
      assert_no_error { assert_have_tag(%Q{<div id="header" class="row columns"></div>}, 'div[class=\'row columns\']') }
    end
    
    it "should handle an basic div tag with id and class attributes with an incorrectly expected attribute" do
      assert_returns_error(%Q{Expected "<div id=\\"header\\" class=\\"row\\"></div>" to have tag ["div#headers"], but no such tag was found}) do 
        assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div#headers')
      end
      
      assert_returns_error(%Q{Expected "<div id=\\"header\\" class=\\"row\\"></div>" to have tag ["div#header.rows"], but no such tag was found}) do 
        assert_have_tag(%Q{<div id="header" class="row"></div>}, 'div#header.rows')
      end
    end
    
    it "should handle a basic label tag with for attribute and nil contents" do
      assert_no_error { assert_have_tag(%Q{<label for="name">Name:</label>\n}, 'label[for=name]', nil) }
    end
    
    it "should handle a basic label tag with for attribute and empty contents" do
      assert_no_error { assert_have_tag(%Q{<label for="name"></label>\n}, 'label[for=name]', '') }
    end
    
    it "should handle a basic label tag with inner_html and empty contents" do
      e = "Expected \"<label for=\\\"name\\\">Username:</label>\" to have tag [\"label[for=name]\"]"
      e << " with contents [\"\"], but the tag content is [Username:]"
      assert_returns_error(e) do
        assert_have_tag(%Q{<label for="name">Username:</label>}, 'label[for=name]', '')
      end
    end
    
    it "should handle a basic label tag with for attribute and contents" do
      assert_no_error { assert_have_tag(%Q{<label for="name">Name:</label>\n}, 'label[for=name]', 'Name:') }
      assert_no_error { assert_have_tag(%Q{<label for="name">User Name:</label>\n}, 'label[for=name]', 'User Name:') }
    end
    
    it "should handle a basic label tag with for attribute and contents with incorrect expectations" do
      assert_no_error { assert_have_tag(%Q{<label for="name">Name:</label>\n}, 'label[for=name]', 'Name:') }
    end
    
    it "should handle a basic label tag with for attribute and Regexp contents" do
      assert_no_error { assert_have_tag(%Q{<label for="name">Username:</label>\n}, 'label[for=name]', /User/) }
      assert_no_error { assert_have_tag(%Q{<label for="name">User Name:</label>\n}, 'label[for=name]', /user/i) }
    end
    
    it "should handle a basic label tag with for attribute and Regexp contents" do
      e = "Expected \"<label for=\\\"name\\\">Username:</label>\" to have tag [\"label[for=name]\"]"
      e << " with inner_html [Username:], but did not match Regexp [/Users/]"
      
      assert_returns_error(e) do
        assert_have_tag(%Q{<label for="name">Username:</label>}, 'label[for=name]', /Users/)
      end
      assert_returns_error(e.sub('Regexp [/Users/]', 'Regexp [/users/i]')) do
        assert_have_tag(%Q{<label for="name">Username:</label>}, 'label[for=name]', /users/i)
      end
    end
    
  end
  
  describe '#.must_have_tag' do
    
    it "should handle nil tag" do
      assert_returns_error('Expected nil to have tag ["br"], but no such tag was found') do 
        nil.must_have_tag('br')
      end
    end
    
    it "should handle empty tag" do
      assert_returns_error('Expected "" to have tag ["br"], but no such tag was found') do 
        ''.must_have_tag('br')
      end
    end
    
    it "should handle a basic br tag" do
      assert_no_error { '<br>'.must_have_tag('br') }
    end
    
    it "should handle an incorrectly expected tag" do
      assert_returns_error('Expected "<br>" to have tag ["brr"], but no such tag was found') do 
        "<br>".must_have_tag('brr')
      end
    end
    
    it "should handle a basic hr tag with a class attribute" do
      assert_no_error { '<hr class="divider">'.must_have_tag('hr[class]') }
    end
    
    it "should handle an basic hr tag with a class attribute with an incorrectly expected attribute" do
      assert_returns_error('Expected "<hr class=\"divider\">" to have tag ["hr[classs]"], but no such tag was found') do 
        '<hr class="divider">'.must_have_tag('hr[classs]')
      end
    end
    
    it "should handle a basic tag with a class attribute" do
      assert_no_error { '<hr class="divider">'.must_have_tag('hr[class=divider]') }
    end
    
    it "should handle an basic tag with a class attribute with an incorrectly expected attribute" do
      assert_returns_error('Expected "<hr class=\"divider\">" to have tag ["hr[class=divder]"], but no such tag was found') do 
        '<hr class="divider">'.must_have_tag('hr[class=divder]')
      end
    end
    
    it "should handle a basic div tag with id and class attributes" do
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div#header') }
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div[id=header]') }
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div.row') }
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div[class=row]') }
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div#header.row') }
      assert_no_error { %Q{<div id="header" class="row"></div>}.must_have_tag('div[id=header][class=row]') }
      assert_no_error { %Q{<div id="header" class="row columns"></div>}.must_have_tag('div[class=\'row columns\']') }
    end
    
    it "should handle an basic div tag with id and class attributes with an incorrectly expected attribute" do
      assert_returns_error(%Q{Expected "<div id=\\"header\\" class=\\"row\\"></div>" to have tag ["div#headers"], but no such tag was found}) do 
        %Q{<div id="header" class="row"></div>}.must_have_tag('div#headers')
      end
      
      assert_returns_error(%Q{Expected "<div id=\\"header\\" class=\\"row\\"></div>" to have tag ["div#header.rows"], but no such tag was found}) do 
        %Q{<div id="header" class="row"></div>}.must_have_tag('div#header.rows')
      end
    end
    
    it "should handle a basic label tag with for attribute and nil contents" do
      assert_no_error { %Q{<label for="name">Name:</label>\n}.must_have_tag('label[for=name]', nil) }
    end
    
    it "should handle a basic label tag with for attribute and empty contents" do
      assert_no_error { %Q{<label for="name"></label>\n}.must_have_tag('label[for=name]', '') }
    end
    
    it "should handle a basic label tag with inner_html and empty contents" do
      e = "Expected \"<label for=\\\"name\\\">Username:</label>\" to have tag [\"label[for=name]\"]"
      e << " with contents [\"\"], but the tag content is [Username:]"
      assert_returns_error(e) do
        %Q{<label for="name">Username:</label>}.must_have_tag('label[for=name]', '')
      end
    end
    
    it "should handle a basic label tag with for attribute and contents" do
      assert_no_error { %Q{<label for="name">Name:</label>\n}.must_have_tag('label[for=name]', 'Name:') }
      assert_no_error { %Q{<label for="name">User Name:</label>\n}.must_have_tag('label[for=name]', 'User Name:') }
    end
    
    it "should handle a basic label tag with for attribute and contents with incorrect expectations" do
      assert_no_error { %Q{<label for="name">Name:</label>\n}.must_have_tag('label[for=name]', 'Name:') }
    end
    
    it "should handle a basic label tag with for attribute and Regexp contents" do
      assert_no_error { %Q{<label for="name">Username:</label>\n}.must_have_tag('label[for=name]', /User/) }
      assert_no_error { %Q{<label for="name">User Name:</label>\n}.must_have_tag('label[for=name]', /user/i) }
    end
    
    it "should handle a basic label tag with for attribute and Regexp contents" do
      e = "Expected \"<label for=\\\"name\\\">Username:</label>\" to have tag [\"label[for=name]\"]"
      e << " with inner_html [Username:], but did not match Regexp [/Users/]"
      
      assert_returns_error(e) do
        %Q{<label for="name">Username:</label>}.must_have_tag('label[for=name]', /Users/)
      end
      assert_returns_error(e.sub('Regexp [/Users/]', 'Regexp [/users/i]')) do
        %Q{<label for="name">Username:</label>}.must_have_tag('label[for=name]', /users/i)
      end
    end
    
  end  
  
  describe '#refute_have_tag' do
    
    it 'should not report an error on non-existant tag' do
      assert_no_error { refute_have_tag('<hr class="divider">', 'br') }
    end
    
    it 'should report an error on present tag' do
      assert_returns_error('Expected "<hr class=\\"divider\\">" to NOT have tag ["hr"], but such a tag was found') do
        refute_have_tag('<hr class="divider">', 'hr') 
      end
    end

    it 'should not report an error on missing id attribute' do
      assert_no_error { refute_have_tag('<hr class="divider">', 'hr[@id]') }
    end
    
    it 'should report an error on present class attribute' do
      assert_returns_error('Expected "<hr class=\\"divider\\">" to NOT have tag ["hr[@class]"], but such a tag was found') do
        refute_have_tag('<hr class="divider">', 'hr[@class]') 
      end
    end
    
  end
  
  describe '#.wont_have_tag' do
    
    it 'should not report an error on non-existant tag' do
      assert_no_error { '<hr class="divider">'.wont_have_tag('br') }
    end
    
    it 'should report an error on present class attribute' do
      assert_returns_error('Expected "<hr class=\\"divider\\">" to NOT have tag ["hr"], but such a tag was found') do
        '<hr class="divider">'.wont_have_tag('hr') 
      end
    end
    
    it 'should not report an error on missing id attribute' do
      assert_no_error { '<hr class="divider">'.wont_have_tag('hr[@id]') }
    end
    
    it 'should report an error on present class attribute' do
      assert_returns_error('Expected "<hr class=\\"divider\\">" to NOT have tag ["hr[@class]"], but such a tag was found') do
        '<hr class="divider">'.wont_have_tag('hr[@class]') 
      end
    end
    
    it 'should not report an error on wrong class attribute value' do
      assert_no_error { '<hr class="divider">'.wont_have_tag('hr[@class=row]') }
    end
    
    it 'should report an error on present correct class attribute value' do
      assert_returns_error('Expected "<hr class=\\"divider\\">" to NOT have tag ["hr[@class=divider]"], but such a tag was found') do
        '<hr class="divider">'.wont_have_tag('hr[@class=divider]') 
      end
    end
    
  end
  
end
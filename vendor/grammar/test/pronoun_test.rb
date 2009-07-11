require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar/pronoun'

class PronounTest < Test::Unit::TestCase
  include Grammar
  
  def test_pronoun_for
    assert_equal 'I', Pronoun.pronoun_for(:first, :singular, :subject)
  end
  
  def test_noun_or_pronoun_with_defaults
    assert_equal 'you', Pronoun.noun_or_pronoun('john', 'john')
    assert_equal 'lucy', Pronoun.noun_or_pronoun('lucy', 'john')
  end
  
  def test_capitalize
    assert_equal 'You', Pronoun.noun_or_pronoun('john', 'john', :capitalize => true)
    assert_equal 'lucy', Pronoun.noun_or_pronoun('lucy', 'john', :capitalize => true)
  end
  
  def test_possessive
    assert_equal 'your', Pronoun.noun_or_pronoun('john', 'john', :case => Grammar::Case::POSSESSIVE)
    assert_equal "lucy's", Pronoun.noun_or_pronoun('lucy', 'john', :case => Grammar::Case::POSSESSIVE)
  end
  
  def test_force_pronoun
    assert_equal 'you', Pronoun.noun_or_pronoun('john', 'john', :force_pronoun => :true)
    assert_equal 'she', Pronoun.noun_or_pronoun('lucy', 'john', :force_pronoun => :true, :gender => Grammar::Gender::FEMALE)
  end
  
  def test_force_noun
    assert_equal 'john', Pronoun.noun_or_pronoun('john', 'john', :force_noun => :true)
    assert_equal 'lucy', Pronoun.noun_or_pronoun('lucy', 'john', :force_noun => :true)
  end
  
end
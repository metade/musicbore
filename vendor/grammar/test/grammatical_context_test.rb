require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar/grammatical_context'

class GrammaticalContextTest < Test::Unit::TestCase

  def test_nil_subject
    c = Grammar::GrammaticalContext.new(:audience => 'john')
    assert_equal '', c.subject
  end

  def test_subject_when_subject_and_audience_differ
    c = Grammar::GrammaticalContext.new(:audience => 'john', :subject => 'lucy')
    assert_equal 'lucy', c.subject(:capitalize => true)
    assert_equal 'lucy', c.subject(:capitalize => false)
  end

  def test_subject_when_subject_and_audience_are_same
    c = Grammar::GrammaticalContext.new(:audience => 'lucy', :subject => 'lucy')
    assert_equal 'You', c.subject(:capitalize => true)
    assert_equal 'you', c.subject(:capitalize => false)
  end

  def test_nil_object
    c = Grammar::GrammaticalContext.new(:audience => 'john')
    assert_equal '', c.object
  end

  def test_object_when_object_and_audience_differ
    c = Grammar::GrammaticalContext.new(:audience => 'john', :object => 'lucy')
    assert_equal 'lucy', c.object(:capitalize => true)
    assert_equal 'lucy', c.object(:capitalize => false)
  end

  def test_object_when_object_and_audience_are_same
    c = Grammar::GrammaticalContext.new(:audience => 'lucy', :object => 'lucy')
    assert_equal 'you', c.object
    assert_equal 'Your', c.object(:capitalize => true, :case => :possessive)
  end

  def test_subject_and_object_and_audience_are_all_same
    c = Grammar::GrammaticalContext.new(:subject => 'dennis', :audience => 'dennis', :object => 'dennis')
    assert_equal 'You', c.subject
    assert_equal 'yourself', c.object
  end

  def test_cannot_conjugate_without_person
    c = Grammar::GrammaticalContext.new(:number => Grammar::Number::PLURAL)
    assert_raises(RuntimeError) { c.conjugate('warn') }
  end

  def test_cannot_conjugate_without_number
    c = Grammar::GrammaticalContext.new(:person => Grammar::Person::THIRD)
    assert_raises(RuntimeError) { c.conjugate('warn') }
  end

  def test_can_conjugate_with_person_and_number
    c = Grammar::GrammaticalContext.new(:number => Grammar::Number::PLURAL, :person => Grammar::Person::THIRD)
    assert_nothing_raised { c.conjugate('ok') }
  end

  def test_third_person_when_subject_and_audience_differ
    c = Grammar::GrammaticalContext.new(:subject => 'dennis', :audience => 'carla')
    assert_equal Grammar::Person::THIRD, c.person
  end

  def test_second_person_when_subject_and_audience_are_same
    c = Grammar::GrammaticalContext.new(:subject => 'queen anne', :audience => 'queen anne')
    assert_equal Grammar::Person::SECOND, c.person
  end

  def test_singular_when_subject_is_singular
    c = Grammar::GrammaticalContext.new(:subject => 'quentin')
    assert_equal Grammar::Number::SINGULAR, c.number

    c = Grammar::GrammaticalContext.new(:subject => ['quentin'])
    assert_equal Grammar::Number::SINGULAR, c.number
  end

  def test_singular_when_subject_is_plural
    c = Grammar::GrammaticalContext.new(:subject => ['quentin', 'leslie'])
    assert_equal Grammar::Number::PLURAL, c.number
  end

  def test_to_hash_with_subject_and_audience
    c = Grammar::GrammaticalContext.new(:subject => 's', :audience => 'a', :object => 'o')
    assert_equal({:subject => 's', :audience => 'a', :object => 'o'}, c.to_hash)
  end

  def test_to_hash_with_person_and_number
    c = Grammar::GrammaticalContext.new(:person => :first, :number => :plural, :audience => 'a', :object => 'o')
    assert_equal({:person => :first, :number => :plural, :audience => 'a', :object => 'o'}, c.to_hash)
  end

  def test_merge_with_subject
    c = Grammar::GrammaticalContext.new(:subject => 's', :audience => 'a', :object => 'o')
    assert_equal 's2', c.merge(:subject => 's2').subject
  end

end
require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar'

class ConjugationTest < Test::Unit::TestCase
  include Grammar
  
  def setup
    @a = Conjugation::ArrayConjugation.new('a', 'b', 'c', 'd', 'eee', 'fff')
    @p = Conjugation::ProcConjugation.new(/foo/) { |verb, person, number| "#{verb} #{person} #{number}"}
  end
  
  def test_array_conjugation_matches
    ['a', 'b', 'c', 'd', 'eee', 'fff'].each do |x|
      assert @a === x
    end
  end
  
  def test_array_conjugation_does_not_match
    ['ab', 'abcdef', 'x', 'y', 'z'].each do |x|
      assert !(@a === x)
    end
  end
  
  def test_array_conjugation_conjugates
    ['a', 'b', 'c', 'd', 'eeee', 'fff'].each do |x|
      assert_equal 'a', @a.conjugate(x, Person::FIRST,  Number::SINGULAR)
      assert_equal 'b', @a.conjugate(x, Person::SECOND, Number::SINGULAR)
      assert_equal 'c', @a.conjugate(x, Person::THIRD,  Number::SINGULAR)
      assert_equal 'd', @a.conjugate(x, Person::FIRST,  Number::PLURAL)
      assert_equal 'eee', @a.conjugate(x, Person::SECOND, Number::PLURAL)
      assert_equal 'fff', @a.conjugate(x, Person::THIRD,  Number::PLURAL)
    end
  end
  
  def test_array_conjugation_retains_case
    assert_equal 'fff', @a.conjugate('a', Person::THIRD,  Number::PLURAL)
    assert_equal 'Fff', @a.conjugate('A', Person::THIRD,  Number::PLURAL)
  end
  
  def test_proc_conjugation_matches
    ['foo', 'food', 'fooer', 'abfoogup'].each do |x|
      assert @p === x
    end
  end
  
  def test_proc_conjugation_does_not_match
    ['bar', 'boo', 'foeo', ''].each do |x|
      assert !(@p === x)
    end
  end
  
  def test_array_conjugation_conjugates
    ['foo'].each do |x|
      assert_equal "#{x} first singular",   @p.conjugate(x, Person::FIRST,  Number::SINGULAR)
      assert_equal "#{x} second singular",  @p.conjugate(x, Person::SECOND, Number::SINGULAR)
      assert_equal "#{x} third singular",   @p.conjugate(x, Person::THIRD,  Number::SINGULAR)
      assert_equal "#{x} first plural",     @p.conjugate(x, Person::FIRST,  Number::PLURAL)
      assert_equal "#{x} second plural",    @p.conjugate(x, Person::SECOND, Number::PLURAL)
      assert_equal "#{x} third plural",     @p.conjugate(x, Person::THIRD,  Number::PLURAL)
    end
  end
  
end

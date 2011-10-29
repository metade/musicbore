require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar/number'
require 'grammar/person'
require 'grammar/gender'
require 'grammar/case'

class PartsOfSpeechTest < Test::Unit::TestCase

  def test_valid_numbers
    [:singular, :plural].each do |n|
      assert Grammar::Number::valid_number?(n)
    end
  end

  def test_invalid_numbers
    [:xsingular, :plurals, 1, 2, nil].each do |n|
      assert !Grammar::Number::valid_number?(n)
    end
  end

  def test_parse_number
    {
      :singular => Grammar::Number::SINGULAR,
      1         => Grammar::Number::SINGULAR,
      [:a]      => Grammar::Number::SINGULAR,
      :plural   => Grammar::Number::PLURAL,
      0         => Grammar::Number::PLURAL,
      2         => Grammar::Number::PLURAL,
      [:a, :b]  => Grammar::Number::PLURAL
    }.each do |k,v|
      assert_equal v, Grammar::Number::parse(k)
    end
  end

  def test_valid_persons
    [:first, :second, :third].each do |p|
      assert Grammar::Person::valid_person?(p)
    end
  end

  def test_invalid_persons
    [1, 2, 3, :ffirst, :fourth, 0, 4, nil].each do |p|
      assert !Grammar::Person::valid_person?(p)
    end
  end

  def test_parse_person
    {
      [:first]        => Grammar::Person::FIRST,
      [1]             => Grammar::Person::FIRST,
      [:second]       => Grammar::Person::SECOND,
      [2]             => Grammar::Person::SECOND,
      ['jon', 'jon']  => Grammar::Person::SECOND,
      [:third]        => Grammar::Person::THIRD,
      [3]             => Grammar::Person::THIRD,
      ['jon', 'ann']  => Grammar::Person::THIRD
    }.each do |k,v|
      assert_equal v, Grammar::Person::parse(*k)
    end
  end

  def test_parse_gender
    {
      'f'       => Grammar::Gender::FEMALE,
      'F'       => Grammar::Gender::FEMALE,
      'female'  => Grammar::Gender::FEMALE,
      'Female'  => Grammar::Gender::FEMALE,
      'm'       => Grammar::Gender::MALE,
      'M'       => Grammar::Gender::MALE,
      'male'    => Grammar::Gender::MALE,
      'Male'    => Grammar::Gender::MALE,
      'n'       => Grammar::Gender::NEUTER,
      'N'       => Grammar::Gender::NEUTER,
      'neuter'  => Grammar::Gender::NEUTER,
      'Neutral' => Grammar::Gender::NEUTER
    }.each do |k,v|
      assert_equal v, Grammar::Gender::parse(k)
    end
  end

  def test_valid_genders
    [:m, :f, :n].each do |g|
      assert Grammar::Gender::valid_gender?(g)
    end
  end

  def test_invalid_genders
    [:male, :female, :neuter, nil].each do |g|
      assert !Grammar::Gender::valid_gender?(g)
    end
  end

end

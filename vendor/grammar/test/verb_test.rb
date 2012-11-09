require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar/conjugator'
require 'grammar/person'
require 'grammar/number'
require 'verbs_to_test'

class VerbTest < Test::Unit::TestCase
  include VerbsToTest

  def self.person_from_index(k)
    case k
    when 0, 3: Grammar::Person::FIRST
    when 1, 4: Grammar::Person::SECOND
    when 2, 5: Grammar::Person::THIRD
    end
  end

  def self.number_from_index(k)
    k > 2 ? Grammar::Number::PLURAL : Grammar::Number::SINGULAR
  end

  Conjugations.each do |c|
    c.each_with_index do |from_form, i|
      from_person = person_from_index(i)
      from_number = number_from_index(i)

      c.each_with_index do |to_form, j|
        to_person = person_from_index(j)
        to_number = number_from_index(j)

        define_method "test_from_#{from_person}_#{from_number}_#{from_form}_to_#{to_person}_#{to_number}_#{to_form}" do
          assert_equal(to_form, Grammar::Conjugator.conjugate(from_form, to_person, to_number))
          assert_equal(to_form.capitalize, Grammar::Conjugator.conjugate(from_form.capitalize, to_person, to_number))
        end
      end
    end
  end

end
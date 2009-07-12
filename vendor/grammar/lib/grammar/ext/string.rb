require 'grammar'

class ::String
  
  def conjugate(person, number)
    Grammar::Conjugator::conjugate(self, person, number)
  end
  
  def first_person_singular
    self.conjugate(Grammar::Person::FIRST, Grammar::Number::SINGULAR)
  end
  
  def second_person_singular
    self.conjugate(Grammar::Person::SECOND, Grammar::Number::SINGULAR)
  end
  
  def third_person_singular
    self.conjugate(Grammar::Person::THIRD, Grammar::Number::SINGULAR)
  end
  
  def first_person_plural
    self.conjugate(Grammar::Person::FIRST, Grammar::Number::PLURAL)
  end
  
  def second_person_plural
    self.conjugate(Grammar::Person::SECOND, Grammar::Number::PLURAL)
  end
  
  def third_person_plural
    self.conjugate(Grammar::Person::THIRD, Grammar::Number::PLURAL)
  end
  
end
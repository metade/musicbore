require 'grammar'

module Grammar::Conjugation
  
  class ProcConjugation
    
    def initialize(matcher, &proc)
      raise ArgumentError.new("No block supplied for #{matcher}") unless block_given?
      self.matcher, self.proc = matcher, proc
    end
  
    def ===(verb)
      matcher === verb
    end
  
    def conjugate(verb, person, number)
      Grammar::Person::validate_person!(person)
      Grammar::Number::validate_number!(number)
      proc.call(verb, person, number)
    end
    
    def to_s
      "ProcConjugation[#{matcher}: #{proc}]"
    end
    
    private
    attr_accessor :matcher, :proc
  
  end
  
  class ArrayConjugation
    
    def initialize(fs, ss, ts, fp, sp, tp)
      self.forms = [fs, ss, ts, fp, sp, tp].map { |x| x.downcase }
    end
    
    def ===(verb)
      forms.include?(verb.downcase)
    end
    
    def conjugate(verb, person, number)
      Grammar::Person::validate_person!(person)
      Grammar::Number::validate_number!(number)
      result = forms[index_for(person, number)]
      capital?(verb) ? result.capitalize : result
    end
    
    def to_s
      "ArrayConjugation[#{forms.join(', ')}]"
    end
    
    private
    
    attr_accessor :forms
    
    def capital?(verb)
      verb =~ /^[A-Z]/
    end
    
    def index_for(person, number)
      i = case number
      when Grammar::Number::SINGULAR: 0
      when Grammar::Number::PLURAL: 3
      end
      j = case person
      when Grammar::Person::FIRST: 0
      when Grammar::Person::SECOND: 1
      when Grammar::Person::THIRD: 2
      end
      i + j
    end
    
  end
  
end
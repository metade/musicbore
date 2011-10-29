require 'grammar'
require 'grammar/conjugation'
require 'singleton'

# Parses Strings into VerbProxies and vice-versa.
module Grammar::Conjugator
  extend self

  def conjugate(verb, person, number)
    return verb if verb.blank? || conjugations.non_conjugations.include?(verb.downcase)
    conjugations.conjugations.find do |c|
      c === verb
    end.conjugate(verb, person, number)
  end

  class Conjugations
    include Singleton

    attr_reader :conjugations
    attr_reader :non_conjugations

    def initialize
      @conjugations, @non_conjugations = [], []
    end

    # Words matching any of +words+ (regardless of case) have all six forms the same; just return the word.
    def do_not_conjugate(*words)
      (@non_conjugations << words).flatten!
    end

    # Things that match +word+ get passed to +block+, along with
    # the desired person and number.
    def conjugate(word, &block)
      raise ArgumentError.new("No block supplied for #{word_or_pattern}") unless block_given?
      @conjugations.insert(0, Grammar::Conjugation::ProcConjugation.new(word, &block))
    end

    def irregular(fs, ss, ts, fp, sp, tp)
      @conjugations.insert(0, Grammar::Conjugation::ArrayConjugation.new(fs, ss, ts, fp, sp, tp))
    end

  end

  # Yields a singleton instance of Grammar::Inflector::Inflections so you can specify additional
  # inflector rules.  (All the following rules are supplied by default.)
  #
  # Example:
  #   Grammar::Conjugator.conjugations do |c|
  #     # all forms are 'came'
  #     c.do_not_conjugate 'came'
  #
  #     # present tense, ending in h: add 'es' on 3rd singular
  #     c.conjugate(/^.*[h]$/i) do |word, person, number|
  #       if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
  #         word + 'es'
  #       else
  #         word
  #       end
  #     end
  #
  #     # Irregular English verb:
  #     c.irregular('was', 'were', 'was', 'were', 'were', 'were')
  #
  #     # a Spanish verb:
  #     c.irregular('estoy', 'estás', 'está', 'estamos', 'estáis', 'estan')
  #   end
  def conjugations
    if block_given?
      yield Grammar::Conjugator::Conjugations.instance
    else
      Grammar::Conjugator::Conjugations.instance
    end
  end

end
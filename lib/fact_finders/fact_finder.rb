require 'rubygems'
require 'activesupport'

$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
require 'ext/array'

$LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','vendor','grammar','lib')
require File.join(File.dirname(__FILE__),'..','..','vendor','grammar','lib','grammar.rb')
require File.join(File.dirname(__FILE__),'..','..','vendor','grammar','lib','grammar','ext','string.rb')

class Subject
  attr_accessor :name

  def initialize(options = {})
    @name = options[:name]
  end

  def pronoun
    'it'
  end

  def inflect_verb(verb)
    verb.third_person_singular
  end
end

class ArtistSubject < Subject
  attr_accessor :name, :gender, :first_name

  def initialize(options = {})
    @name = options[:name]
    @gender = options[:gender]
    @first_name = options[:first_name]
  end

  def pronoun
    case gender
    when :male then "He"
    when :female then "She"
    else "They"
    end
  end

  def inflect_verb(verb)
    case gender
    when :male then verb.third_person_singular
    when :female then verb.third_person_singular
    else verb.third_person_plural
    end
  end
end

class Fact
  attr_accessor :subject, :verb_phrase, :object

  def initialize(options = {})
    @subject = options[:subject]
    @verb_phrase = options[:verb_phrase]
    @object = options[:object]
  end

  def inflected_verb_phrase
    verb = verb_phrase.split.first
    inflected_verb = subject.inflect_verb(verb)
    verb_phrase.gsub(verb,inflected_verb)
  end

  def first_sentence
    [subject.name, inflected_verb_phrase, object].join(" ")
  end

  def subsequent_sentence
    return first_sentence if rand>0.8
    pronoun = (subject.first_name and rand > 0.5) ? subject.first_name.titleize : subject.pronoun
    [pronoun, inflected_verb_phrase, object].join(" ")
  end

  def final_sentence
    ["and", inflected_verb_phrase, object].join(" ")
  end

  def to_s
    subsequent_sentence
  end
end

class FreeformFact < Fact
  def initialize(options={})
    @sentence = options[:sentence]
  end

  def first_sentence
    @sentence
  end

  def subsequent_sentence
    @sentence
  end

  def final_sentence
    @sentence
  end
end

class FactFinder

  def name
  end

  def gender
  end

  def group?
  end

  def statements
  end

  def bla_bla_bla
    list = statements
    return if (list.nil? or list.empty?)
    facts = list.sort { |a,b| rand(3)-1 }
    string = facts.pop.first_sentence + '. '
    facts.each do |fact|
      break if (string.size > 200)
      string += fact.subsequent_sentence + '. '
    end
    string
  end

  protected

  def tidy_url(url)
    return nil if url.nil?
    url_s = url.uri.to_s
    url_s = $1 if url_s =~ %r[http://www.(.*)]
    url_s
  end
end

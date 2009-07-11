class Subject
  attr_accessor :name
  
  def initialize(options = {})
    @name = options[:name]
  end
  
  def pronoun
    'it'
  end
end

class ArtistSubject < Subject
  attr_accessor :name, :gender
  
  def initialize(options = {})
    @name = options[:name]
    @gender = options[:gender]
  end
  
  def pronoun
    case gender
    when "Male" then "He"
    when "Female" then "She"
    else "They"
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

  def first_sentence
    [subject, self.verb_phrase, self.object].join(" ")
  end

  def subsequent_sentence
    [subject, self.verb_phrase, self.object].join(" ")
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
    facts = list_statements
    [facts.pop.first_sentence,
      facts.map {|f| f.subsequent_sentence}].flatten
  end
  
  protected
  
  def tidy_url(url)
    return nil if url.nil?
    url_s = url.uri.to_s 
    url_s = $1 if url_s =~ %r[http://www.(.*)]
    url_s
  end
end

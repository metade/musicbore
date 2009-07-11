require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','fact_finders','fact_finder.rb')
 
class TestFactFinder < Test::Unit::TestCase
 
  def test_fact_male
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Bob", :gender => "Male"),
                    :verb_phrase => "has a big bag full of",
                    :object => "door knobs")
    assert_equal(fact.first_sentence, "Bob has a big bag full of door knobs")
    assert_equal(fact.subsequent_sentence, "He has a big bag full of door knobs")
  end
  
  def test_fact_band
    fact = Fact.new(:subject => ArtistSubject.new(:name => "The Smiths"),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal(fact.first_sentence, "The Smiths sound like U2")
    assert_equal(fact.subsequent_sentence, "They sound like U2")
  end
  
  def test_fact_male_artist
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Michael Jackson", :gender => "Male"),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal(fact.first_sentence, "Michael Jackson sounds like U2")
    assert_equal(fact.subsequent_sentence, "He sounds like U2")
  end
  
  def test_fact_female_artist
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Janet Jackson", :gender => "Female"),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal(fact.first_sentence, "Janet Jackson sounds like U2")
    assert_equal(fact.subsequent_sentence, "She sounds like U2")
  end
 
end

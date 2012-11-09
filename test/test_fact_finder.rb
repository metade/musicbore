require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','fact_finders','fact_finder.rb')

class TestFactFinder < Test::Unit::TestCase

  def test_fact_male
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Bob", :gender => :male),
                    :verb_phrase => "has a big bag full of",
                    :object => "door knobs")
    assert_equal("Bob has a big bag full of door knobs", fact.first_sentence)
    assert_equal("He has a big bag full of door knobs", fact.subsequent_sentence)
  end

  def test_fact_band
    fact = Fact.new(:subject => ArtistSubject.new(:name => "The Smiths"),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal( "The Smiths sound like U2", fact.first_sentence)
    assert_equal("They sound like U2", fact.subsequent_sentence)
  end

  def test_fact_band_with_has
    fact = Fact.new(:subject => ArtistSubject.new(:name => "The Smiths"),
                    :verb_phrase => "has a picture of",
                    :object => "some cats")
    assert_equal( "The Smiths have a picture of some cats", fact.first_sentence)
    assert_equal("They have a picture of some cats", fact.subsequent_sentence)
  end

  def test_fact_male_artist
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Michael Jackson", :gender => :male),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal("Michael Jackson sounds like U2", fact.first_sentence)
    assert_equal("He sounds like U2", fact.subsequent_sentence)
  end

  def test_fact_female_artist
    fact = Fact.new(:subject => ArtistSubject.new(:name => "Janet Jackson", :gender => :female),
                    :verb_phrase => "sound like",
                    :object => "U2")
    assert_equal("Janet Jackson sounds like U2",fact.first_sentence)
    assert_equal("She sounds like U2", fact.subsequent_sentence)
  end
end

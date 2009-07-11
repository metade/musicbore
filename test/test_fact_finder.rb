require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','fact_finders','fact_finder.rb')
 
class TestFactFinder < Test::Unit::TestCase
 
  def test_fact
    fact = Fact.new(:subject => Subject.new(:name => "Bob", :gender => "Male"),
                    :verb_phrase => "has a big bag full of",
                    :object => "door knobs")
    assert_equal(fact.first_sentence, "Bob has a big bag full of door knobs")
  end
 
end

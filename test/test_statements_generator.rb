require 'test/unit'
require File.join(File.dirname(__FILE__),'..','lib','fact_finders','fact_finder.rb')

class MockFactFinder < FactFinder
  attr_accessor :list_statements

  def initialize
    @list_statements = []
  end
end

class TestFactFinder < Test::Unit::TestCase



  def setup
    @mock = MockFactFinder.new
    5.times do
      @mock.list_statements << Fact.new(:subject => ArtistSubject.new(:name => "Janet Jackson", :gender => :female),
                                       :verb_phrase => "sound like",
                                       :object => "U2")
    end
  end


  def test_final_statement_should_start_with_and
    puts @mock.statements.last
    assert_equal("and", @mock.statements.last.split.first)
  end

end

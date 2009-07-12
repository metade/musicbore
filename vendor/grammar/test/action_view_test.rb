require File.join(File.dirname(__FILE__), 'test_helper')
gem 'actionpack', '>= 2.1'
require 'action_controller'
require 'action_controller/cgi_ext'
require 'action_controller/test_process'
require 'action_view'
require 'grammar'
require 'grammar/ext/action_view'
require 'action_view/test_case'

class ActionViewTest < ActionView::TestCase
  tests Grammar::Ext::ActionView
  #include Grammar::Ext::ActionView
  #include ActionView::Helpers::CaptureHelper
  #include ActionView::Helpers::TextHelper
  
  attr_reader :grammatical_context

  def setup
    @grammatical_context = Grammar::GrammaticalContext.new(:audience => 'Luke', :object => 'Luke', :subject => 'Barb')
    @erbout = ''
  end
  
  def _erbout
    @erbout
  end
  
  def test_with_grammatical_context
    with_grammatical_context { |gc| _erbout.concat "#{gc.subject} #{gc.conjugate('know')} #{gc.object}" }

    expected = %(Barb knows you)
    assert_dom_equal expected, _erbout
  end
  
  def test_with_grammatical_context_with_additional_options_supplied
    with_grammatical_context(:audience => 'Barb') { |gc| _erbout.concat "#{gc.subject} #{gc.conjugate('know')} #{gc.object}" }

    expected = %(You know Luke)
    assert_dom_equal expected, _erbout
  end
  
  def test_with_grammatical_context_with_context_supplied
    c = Grammar::GrammaticalContext.new(:audience => 'Barb', :object => 'Barb')
    with_grammatical_context(c) { |gc| _erbout.concat "#{gc.subject} #{gc.conjugate('know')} #{gc.object}" }

    expected = %(You know yourself)
    assert_dom_equal expected, _erbout
  end
  
end

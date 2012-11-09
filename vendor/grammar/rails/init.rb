require 'grammar'
require 'grammar/ext/string'
require 'grammar/ext/action_controller'
require 'grammar/ext/action_view'

ActionController::Base.class_eval do

  def self.is_grammatical
    include Grammar::Ext::ActionController
    helper Grammar::Ext::ActionView
  end

end
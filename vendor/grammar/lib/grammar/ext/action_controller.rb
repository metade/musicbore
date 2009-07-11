require 'grammar/ext'

# Mixin support for ActionController.
# Can be included directly or by calling +is_grammatical+. The following
# is the recommended way of including this module:
#
#   class FooController < ApplicationController
#     is_grammatical
#
#     # load the users _before_ creating the grammatical context:
#     append_before_filter :load_current_user
#     append_before_filter :load_requested_user
#     append_before_filter :load_grammatical_context
#
#     ...
#
#     private
#
#     def load_grammatical_context
#       Grammar::GrammaticalContext.new(:subject => @requested_user, :audience => @current_user)
#     end
#   end
# 
module Grammar::Ext::ActionController
  
  def self.included(base)
    base.send :include, Grammar::Ext::ActionController::InstanceMethods
    base.helper_method :grammatical_context
  end
  
  module InstanceMethods
    
    def grammatical_context
      @grammatical_context ||= Grammar::GrammaticalContext.new
    end
    
    private
    
    def grammatical_context=(context)
      @grammatical_context = context
    end
    
  end
  
end
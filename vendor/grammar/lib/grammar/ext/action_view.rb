require 'grammar/ext'

# Mixin support for ActionView.
# Can be included directly in a helper or by calling +is_grammatical+.
# The following is the recommended way of using this module:
#
#   # in app/controllers/news_controller.rb:
#   class NewsController < ApplicationController
#     is_grammatical
#     ...
#     append_before_filter :load_grammatical_context
#     ...
#     def load_grammatical_context
#       Grammar::GrammaticalContext.new(:audience => self.current_user)
#     end
#   end
#
#   # in app/views/news/index.html.erb:
#   ...
#   <% @news_items.each do |item| -%>
#     <% with_grammatical_context(:subject => item.follower, :object => item.followee) do |gc| -%>
#       <%= gc.subject %> <%= gc.conjugate('is') %> now following <%= gc.object %>.
#     <% end -%>
#   <% end -%>
module Grammar::Ext::ActionView

  # Set up and yield a GrammaticalContext to help generate inflected strings.
  #
  # If +options_or_context+ is a GrammaticalContext, uses that context.
  # If +GrammaticalContext+ is a Hash, merges those values with the context
  # in self.grammatical_context, if any.  Otherwise, uses an empty context
  # (which will cause an error if you call conjugate(verb) on it).
  def with_grammatical_context(options_or_context = nil, &block) #:yields context
    context = case options_or_context
    when nil
      self.grammatical_context
    when Hash, Grammar::GrammaticalContext
      self.grammatical_context.merge(options_or_context.to_hash)
    else
      raise "I don't know how to use #{options_or_context} as a GrammaticalContext"
    end

    concat(capture(context, &block), block.binding)
  end

end
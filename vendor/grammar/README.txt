Grammar adds verb and pronoun inflection support to ActiveSupport.

With Grammar, you can do things like
  'am'.second_person_plural
  # => 'are'

  'have'.third_person_singular
  # => 'has'

and
  @current_user = @john
  @user_to_display = @lucy
  Grammar::Pronoun.noun_or_pronoun(@user_to_display, @current_user)
  # => 'John'
	
  @current_user = @lucy
  Grammar::Pronoun.pronoun_or_noun(@user_to_display, @current_user)
  # => 'you'

If you're using Rails (specifically, ActionPack), you can do the following:
  # in app/controllers/news_controller.rb:
  class NewsController < ApplicationController
    is_grammatical
    ...
    append_before_filter :load_grammatical_context
    ...
    def load_grammatical_context
      Grammar::GrammaticalContext.new(:audience => self.current_user)
    end
  end

  # in app/views/news/index.html.erb:
  ...
  <% @news_items.each do |item| -%>
    <% with_grammatical_context(:subject => item.follower, :object => item.followee) do |gc| -%>
      <%= gc.subject %> <%= gc.conjugate('is') %> now following <%= gc.object %>.
    <% end -%>
  <% end -%>
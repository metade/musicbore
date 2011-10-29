require 'grammar/pronoun'
require 'grammar/person'
require 'grammar/number'
require 'grammar/conjugator'

# Example usage:
#   # John is looking at his own profile:
#   c = GrammaticalContext.new(:subject => @john, :audience => @john)
#   c.subject
#   # => 'you'
#   c.subject(:capitalize => true)
#   # => 'You'
#
#   # Lucy is looking at John's profile
#   c = GrammaticalContext.new(:subject => @john, :audience => @lucy)
#   c.subject
#   # => 'john'
#   c.subject(:capitalize => true)
#   # => 'john'    #won't capitalize user's names
#
#   # Generate an error message for Greg trying to add himself to his own friends list:
#   c = GrammaticalContext.new(:subject => @greg, :audience => @greg, :object => @greg)
#   "#{c.subject} can't add #{c.object} to #{c.subject, :possessive => true} friends list!"
#   # => "You can't add yourself to your friends list!"
class Grammar::GrammaticalContext
  include Grammar::Pronoun

  attr_reader :audience

  # Options:
  # * <tt>:subject</tt> - the subject of verbs to be conjugated
  # * <tt>:object</tt> - the object of verbs to be conjugated
  # * <tt>:audience</tt> - the audience of verbs to be conjugated
  # * <tt>:person</tt> - the person (:first, :second, or :third) of verbs
  #   to be conjugated; determined from :subject and :audience if +nil+
  # * <tt>:number</tt> - the number (:singular or :plural) of verbs to
  #   be conjugated; determined from :subject if nil
  def initialize(opts = {})
    @subject, @object, @audience, @person, @number = opts[:subject], opts[:object], opts[:audience], opts[:person], opts[:number]
  end

  # Yields the result of <tt>merge(options)</tt>.
  #
  # Returns the result of the yield.
  def with_options(options, &block)
    raise ArgumentError.new("No block supplied to GrammaticalContext:with_options") unless block_given?
    yield merge(options)
  end

  # Returns a Hash with all the same options needed to recreate this
  # GrammaticalContext.  (This will only include :person and :number
  # if they cannot be inferred from :subject and :audience.)
  def to_hash
    h = {}
    h[:subject] = @subject if @subject
    h[:object] = @object if @object
    h[:audience] = @audience if @audience
    h[:person] = @person if @person
    h[:number] = @number if @number
    h
  end

  # Returns a new GrammaticalContext with the values in +self+ replaced
  # by those in +options+ (a GrammaticalContext or a Hash of the same
  # structure as for a +new+ Context).
  def merge(options)
    Grammar::GrammaticalContext.new(self.to_hash.merge(options.to_hash))
  end

  def person
    # If none was specified at creation, try to calculate it from subject
    # and audience, but store the result in a separate variable so as not
    # to override @person for hashes and merges.
    return @person if @person
    @calculated_person ||= Grammar::Person::parse(@subject, @audience) if @subject && @audience
  end

  def number
    # If none was specified at creation, try to calculate it from subject, but
    # store the result in a separate variable so as not
    # to override @number for hashes and merges.
    return @number if @number
    @calculated_number ||= Grammar::Number::parse(@subject) if @subject
  end

  # Returns a String representing the subject of this context, replacing
  # with 'you' or 'yourself' depending on the audience.
  # Options:
  # * :force_pronoun - force conversion to pronoun; defaults to +false+
  # * :capitalize - capitalize the result, but only if it's a pronoun; defaults to +true+
  # * :case - one of Grammar::Case::VALID_VALUES; defaults to SUBJECT
  # * :gender - the gender of the pronoun (only needed if :force_pronoun is +true+); defaults to Grammar::Gender::NEUTER
  def subject(options = {})
    options = { :capitalize => true, :case => Grammar::Case::SUBJECT }.merge(options)
    pronoun_or_noun(@subject, @audience, options)
  end

  # Returns a String representing the object of this context, replacing
  # with 'you' or 'yourself' depending on the audience.
  # Options:
  # * :force_pronoun - force conversion to pronoun; defaults to +false+
  # * :capitalize - capitalize the result, but only if it's a pronoun; defaults to +false+
  # * :case - one of Grammar::Case::VALID_VALUES; defaults to REFLEXIVE if @subject == @object, otherwise DIRECT_OBJECT
  # * :gender - the gender of the pronoun (only needed if :force_pronoun is +true+); defaults to Grammar::Gender::NEUTER
  def object(options = {})
    kase = @subject == @object ? Grammar::Case::REFLEXIVE : Grammar::Case::DIRECT_OBJECT
    options = { :case => kase }.merge(options)
    pronoun_or_noun(@object, @audience, options)
  end

  def conjugate(verb)
    missing = []
    missing << 'person' unless self.person
    missing << 'number' unless self.number
    raise "Cannot conjugate; no #{missing.join(' or ')} specified" unless missing.empty?
    Grammar::Conjugator::conjugate(verb, self.person, self.number)
  end

  def ==(other)
    other.kind_of?(GrammaticalContext) && self.to_hash == other.to_hash
  end

end
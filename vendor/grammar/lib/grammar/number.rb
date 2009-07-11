require 'grammar'

module Grammar::Number
  
  SINGULAR = :singular
  PLURAL = :plural
  
  ALLOWED_VALUES = [SINGULAR, PLURAL]
  
  # Converts +n_or_subject+ to <tt>:singular</tt> or <tt>:plural</tt>
  # as follows:
  # * if +n_or_subject+ is Nil, <tt>:plural</tt>
  # * if +n_or_subject+ is a Symbol, do nothing to it
  # * if +n_or_subject+ is a Numeric, <tt>:singular</tt> if <tt>n_or_subject == 1</tt>, else <tt>:plural</tt>
  # * if +n_or_subject+ responds to <tt>many?</tt>, <tt>:plural</tt> if <tt>n_or_subject.many?</tt>, else <tt>:plural</tt>
  # * if +n_or_subject+ responds to <tt>several?</tt>, <tt>:plural</tt> if <tt>n_or_subject.many?</tt>, else <tt>:plural</tt>
  # * if +n_or_subject+ responds to +size+ (but is not a Numeric), convert to a Numeric, then process as above
  # * if +n_or_subject+ responds to +length+ (but is not a Numeric), convert to a Numeric, then process as above
  # * otherwise, :singular
  def self.parse(n_or_subject)
    if n_or_subject.nil?
      :plural
    elsif n_or_subject.kind_of?(Symbol)
      n_or_subject
    elsif n_or_subject.kind_of?(Numeric)
      n_or_subject == 1 ? :singular : :plural
    elsif n_or_subject.respond_to?(:many?)
      n_or_subject.many? ? :plural : :singular
    elsif n_or_subject.respond_to?(:several?)
      n_or_subject.several? ? :plural : :singular
    elsif n_or_subject.kind_of?(Array)
      n_or_subject.size == 1 ? :singular : :plural
    else
      :singular
    end
  end
  
  # Whether +n+ is a valid verb number.
  def self.valid_number?(n)
    ALLOWED_VALUES.include?(n)
  end
  
  # Raises an ArgumentError unless +number+ is a valid verb number.
  def self.validate_number!(number)
    raise ArgumentError.new('#{number} is not a valid verb number') unless valid_number?(number)
  end
  
end
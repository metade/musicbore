require 'grammar'

module Grammar::Person
  
  # First person; e.g. 'I guide' or 'We decided'
  FIRST = :first
  
  # Second person; e.g. 'You dance' or 'You (all) will compare'.
  SECOND = :second
  
  # Third person; e.g. 'He complains' or 'She had given' or 'They will weave'
  THIRD = :third
  
  ALLOWED_VALUES = [FIRST, SECOND, THIRD]
  
  # Converts +i+ and +j+ to one of <tt>[FIRST, SECOND, THIRD]</tt> as follows:
  # * if +i+ is a Symbol, +i+
  # * if +i+ is one of [1, 2, 3], returns FIRST, SECOND, or THIRD, respectively
  # * else treats +i+ and +j+ as subject and addressee, respecively, returning
  #   SECOND if +i+ and +j+ are equal, otherwise THIRD.
  #
  # Raises ArgumentError if the result is not a valid verb person.
  def self.parse(i, j = nil)
    s = case i
    when Symbol, nil
      i
    when 1
      FIRST
    when 2
      SECOND
    when 3
      THIRD
    when Symbol
      i
    else
      i == j ? SECOND : THIRD
    end
    validate_person!(s)
    s
  end
  
  # Whether +n+ is a valid verb person.
  def self.valid_person?(n)
    ALLOWED_VALUES.include?(n)
  end
  
  # Raises an ArgumentError unless +number+ is a valid verb person.
  def self.validate_person!(person)
    raise ArgumentError.new('#{person} is not a valid verb person') unless valid_person?(person)
  end
  
end
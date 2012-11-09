require 'grammar'
module Grammar::Case


  SUBJECT = :subject

  NOMINATIVE = SUBJECT

  POSSESSIVE = :possessive

  GENETIVE = POSSESSIVE

  DIRECT_OBJECT = :direct_object

  ACCUSATIVE = DIRECT_OBJECT

  INDIRECT_OBJECT = :indirect_object

  DATIVE = INDIRECT_OBJECT

  REFLEXIVE = :reflexive

  ALLOWED_VALUES = [SUBJECT, DIRECT_OBJECT, INDIRECT_OBJECT, REFLEXIVE, POSSESSIVE]

  # Returns +kase+ if it is a valid pronoun case; otherwise, raises
  # an ArgumentError.
  def self.parse(kase)
    validate_case!(kase)
    kase
  end

  # Whether +kase+ is a valid pronoun case.
  def self.valid_case?(kase)
    ALLOWED_VALUES.include?(kase)
  end

  # Raises an ArgumentError unless +kase+ is a valid pronoun case.
  def self.validate_case!(kase)
    raise ArgumentError.new('#{kase} is not a valid pronoun case') unless valid_case?(kase)
  end

end
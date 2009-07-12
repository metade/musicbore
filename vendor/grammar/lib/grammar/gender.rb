require 'grammar'
module Grammar::Gender
  
  FEMALE = :f
  MALE = :m
  NEUTER = :n
  
  ALLOWED_VALUES = [FEMALE, MALE, NEUTER]
  
  # Tries to parse +g+ to a valid pronoun gender.
  #
  # Raises an ArgumentError if the gender could not be determined.
  def self.parse(g)
    if g.respond_to?(:gender) && !g.gender.nil? && g.gender != g
      parse(g.gender)
    end
    case g.to_s
    when /f/i
      FEMALE
    when /m/i
      MALE
    when /n/i
      NEUTER
    else
      raise ArgumentError.new("Could not parse #{g} as a gender")
    end
  end
  
  # Whether +g+ is a valid pronoun gender.
  def self.valid_gender?(g)
    ALLOWED_VALUES.include?(g)
  end
  
  # Raises an ArgumentError unless +gender+ is a valid pronoun gender.
  def self.validate_gender!(gender)
    raise ArgumentError.new('#{gender} is not a valid pronoun gender') unless valid_gender?(gender)
  end
  
end
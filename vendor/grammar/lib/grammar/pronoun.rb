require 'grammar'
require 'grammar/person'
require 'grammar/number'
require 'grammar/gender'
require 'grammar/case'

module Grammar::Pronoun
  extend self

  # Get the pronoun for +person+, +number+, +kase+, and +gender+.
  #
  # Raises ArgumentError if any of the arguments is invalid.
  def pronoun_for(person, number, kase, gender = nil)
    Grammar::Person::validate_person!(person)
    Grammar::Number::validate_number!(number)
    Grammar::Case::validate_case!(kase)

    case person
    when Grammar::Person::FIRST, Grammar::Person::SECOND
      load_pronouns[person][number][kase]
    when Grammar::Person::THIRD
      Grammar::Gender::validate_gender!(gender)
      load_pronouns[person][number][kase][gender]
    end
  end

  # Return a pronoun or a noun, depending on the relationship of +noun+
  # to +audience+.  If they are the same, infers second person and uses
  # 'you'.  If they differ, uses <tt>noun.to_s</tt>
  #
  # Options:
  # * <tt>:force_pronoun</tt> - use a pronoun regardless of the relationship
  #   of +noun+ to +audience+, but still infer +person+ (so return 'she',
  #   'his', 'themsleves', etc.); defaults to +false+
  # * <tt>:force_noun</tt> - use <tt>noun.to_s</tt>, regardless of the
  #   relationship of +noun+ to +audience+
  # * <tt>:capitalize</tt> - capitalize the result, but only if it's a
  #   pronoun; defaults to false
  # * <tt>:case</tt> - the case of the pronoun or noun; defaults to :subject
  # * <tt>:gender</tt> - the gender of the pronoun to use (used only if
  #   <tt>:force_pronoun</tt> in English; other languages have
  #   gendered second-person pronouns).
  def pronoun_or_noun(noun, audience, options = {})
    return '' if noun.blank?

    options = {
      :force_pronoun => false,
      :force_noun => false,
      :capitalize => false,
      :case => Grammar::Case::SUBJECT
    }.merge(options)

    person = Grammar::Person::parse(noun, audience)

    if options[:force_noun] || (person == Grammar::Person::THIRD && !options[:force_pronoun])
      result = noun.to_s
      result += "'s" if options[:case] == Grammar::Case::POSSESSIVE
    else
      number = Grammar::Number::parse(noun)
      gender = options[:gender] || (Grammar::Gender::parse(noun) rescue Grammar::Gender::NEUTER)
      kase = options[:case]
      result = Grammar::Pronoun::pronoun_for(person, number, kase, gender)
      result = options[:capitalize] ? result.capitalize : result.downcase
    end
    result
  end

  # Alias for +pronoun_or_noun+.
  def noun_or_pronoun(noun, audience, options = {})
    pronoun_or_noun(noun, audience, options)
  end

  private

  @@pronouns = nil

  def self.load_pronouns
    return @@pronouns unless @@pronouns.nil?
    h = {
      Grammar::Person::FIRST => {
        Grammar::Number::SINGULAR => {
          Grammar::Case::SUBJECT => 'I',
          Grammar::Case::DIRECT_OBJECT => 'me',
          Grammar::Case::POSSESSIVE => 'my',
          Grammar::Case::REFLEXIVE => 'myself'
        },
        Grammar::Number::PLURAL => {
          Grammar::Case::SUBJECT => 'We',
          Grammar::Case::DIRECT_OBJECT => 'us',
          Grammar::Case::POSSESSIVE => 'our',
          Grammar::Case::REFLEXIVE => 'ourselves'
        }
      },
      Grammar::Person::SECOND => {
        Grammar::Number::SINGULAR => {
          Grammar::Case::SUBJECT => 'You',
          Grammar::Case::DIRECT_OBJECT => 'you',
          Grammar::Case::POSSESSIVE => 'your',
          Grammar::Case::REFLEXIVE => 'yourself'
        },
        Grammar::Number::PLURAL => {
          Grammar::Case::SUBJECT => 'You',
          Grammar::Case::DIRECT_OBJECT => 'you',
          Grammar::Case::POSSESSIVE => 'your',
          Grammar::Case::REFLEXIVE => 'yourselves'
        }
      },
      Grammar::Person::THIRD => {
        Grammar::Number::SINGULAR => {
          Grammar::Case::SUBJECT => {
            Grammar::Gender::FEMALE => 'She',
            Grammar::Gender::MALE => 'He',
            Grammar::Gender::NEUTER => 'They'
          },
          Grammar::Case::DIRECT_OBJECT => {
            Grammar::Gender::FEMALE => 'her',
            Grammar::Gender::MALE => 'him',
            Grammar::Gender::NEUTER => 'them'
          },
          Grammar::Case::POSSESSIVE => {
            Grammar::Gender::FEMALE => 'her',
            Grammar::Gender::MALE => 'his',
            Grammar::Gender::NEUTER => 'their'
          },
          Grammar::Case::REFLEXIVE => {
            Grammar::Gender::FEMALE => 'herself',
            Grammar::Gender::MALE => 'himself',
            Grammar::Gender::NEUTER => 'themselves'
          }
        },
        Grammar::Number::PLURAL => {
          Grammar::Case::SUBJECT => {
            Grammar::Gender::FEMALE => 'They',
            Grammar::Gender::MALE => 'They',
            Grammar::Gender::NEUTER => 'They'
          },
          Grammar::Case::DIRECT_OBJECT => {
            Grammar::Gender::FEMALE => 'them',
            Grammar::Gender::MALE => 'them',
            Grammar::Gender::NEUTER => 'them'
          },
          Grammar::Case::POSSESSIVE => {
            Grammar::Gender::FEMALE => 'their',
            Grammar::Gender::MALE => 'their',
            Grammar::Gender::NEUTER => 'their'
          },
          Grammar::Case::REFLEXIVE => {
            Grammar::Gender::FEMALE => 'themselves',
            Grammar::Gender::MALE => 'themselves',
            Grammar::Gender::NEUTER => 'themselves'
          }
        }
      }
    }
    @@pronouns = h
  end

end
require 'grammar/conjugator'

# Define conjugations in order of inverse priority.  Defaults at the top,
# exceptions at the bottom.
Grammar::Conjugator::conjugations do |c|
  
  # default: do nothing
  c.conjugate(/^.*$/i) { |word, person, number| word }
  
  # present tense, not ending in h: add 's' on 3rd singular
  c.conjugate(/^.*[^h]$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word + 's'
    else
      word
    end
  end
  
  # present tense, ending in h: add 'es' on 3rd singular
  c.conjugate(/^.*[h]$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word + 'es'
    else
      word
    end
  end
  
  # present tense, ending in 'es': keep 's' only on 3rd singular
  c.conjugate(/^.*[^h]e?s$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word
    else
      word.gsub(/s$/, '')
    end
  end
  
  # present tense, ending in 'hes': keep 'es' only on 3rd singular
  c.conjugate(/^.*hes$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word
    else
      word.gsub(/es$/, '')
    end
  end
  
  # present tense, ending in 'ies': change 'ies' to 'y' on everything but 3rd singular
  c.conjugate(/^.*ies$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word
    else
      word.gsub(/ies$/, 'y')
    end
  end

  # present tense, ending in consonant follow by 'y': change 'y' to 'ies' on 3rd singular
  c.conjugate(/^.*[^aeiou]y$/i) do |word, person, number|
    if person == Grammar::Person::THIRD && number == Grammar::Number::SINGULAR
      word.gsub(/y$/, 'ies')
    else
      word
    end
  end
  
  # past tense: all forms the same
  c.conjugate(/^.*ed$/i) { |word, person, number| word }
  c.do_not_conjugate(
    'arose',
    'awoke',
    'bade',
    'began',
    'bent',
    'bet',
    'bit',
    'blew',
    'bore',
    'bought',
    'broadcast',
    'broke',
    'built',
    'came',
    'chose',
    'clung',
    'crept',
    'cut',
    'did',
    'drank',
    'dug',
    'dwelt',
    'fell',
    'flew',
    'forgot',
    'fought',
    'found',
    'froze',
    'grew',
    'had',
    'hid',
    'kept',
    'knew',
    'laid',
    'left',
    'lied',
    'lost',
    'made',
    'meant',
    'met',
    'misread',
    'mistyped',
    'miswrote',
    'outbid',
    'outran',
    'overdid',
    'overran',
    'overspent',
    'overwrote',
    'paid',
    'prebuilt',
    'predid',
    'premade',
    'prepaid',
    'presold',
    'put',
    'quit',
    'ran',
    'read',
    'rebroadcast',
    'recut',
    'redrew',
    'remade',
    'repaid',
    'reran',
    'resold',
    'resent',
    'rewrote',
    'rode',
    'rose',
    'said',
    'sat',
    'saw',
    'shot',
    'slept',
    'slid',
    'spoke',
    'sold',
    'sought',
    'spoke',
    'strove',
    'struck',
    'stuck',
    'telecast',
    'threw',
    'thrust',
    'told',
    'took',
    'typewrote',
    'undercut',
    'undersold',
    'understood',
    'undertook',
    'underwent',
    'underwrote',
    'undid',
    'unfroze',
    'unhid',
    'unstuck',
    'went',
    'withheld',
    'withstood',
    'woke',
    'won',
    'wrote'
  )

  # weirdo forms
  c.irregular('am', 'are', 'is', 'are', 'are', 'are')
  c.irregular('do', 'do', 'does', 'do', 'do', 'do')
  c.irregular('was', 'were', 'was', 'were', 'were', 'were')
  c.irregular('have', 'have', 'has', 'have', 'have', 'have')
end
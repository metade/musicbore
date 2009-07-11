Gem::Specification.new do |s|
  s.name = 'grammar'
  s.version = '1.0.0'
  s.date = '2008-06-18'
  s.summary = 'Verb and pronoun inflection.'
  s.description = "Makes it easy to get the right form of the verb or use 'you' correctly in your View."
 
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  
  s.authors = ['James Rosen']
  s.email = 'james.a.rosen@gmail.com'
  
  s.extra_rdoc_files = ['init.rb', 'rails/init.rb', 'README.txt', 'License.txt']
  s.files = [
    '.gitignore', 'doc', 'doc/.gitignore', 'doc/jamis_template.rb',
    'grammar.gemspec', 'init.rb', 'lib', 'lib/grammar', 'lib/grammar/case.rb',
    'lib/grammar/conjugation.rb', 'lib/grammar/conjugations.rb',
    'lib/grammar/conjugator.rb', 'lib/grammar/ext',
    'lib/grammar/ext/action_controller.rb', 'lib/grammar/ext/action_view.rb',
    'lib/grammar/ext/string.rb', 'lib/grammar/ext.rb',
    'lib/grammar/gender.rb', 'lib/grammar/grammatical_context.rb',
    'lib/grammar/number.rb', 'lib/grammar/person.rb',
    'lib/grammar/pronoun.rb', 'lib/grammar.rb', 'License.txt', 'rails',
    'rails/init.rb', 'Rakefile', 'README.txt', 'test',
    'test/action_view_test.rb', 'test/conjugation_test.rb',
    'test/grammatical_context_test.rb', 'test/lib',
    'test/lib/verbs_to_test.rb', 'test/parts_of_speech_test.rb',
    'test/pronoun_test.rb', 'test/string_ext_test.rb', 'test/test_helper.rb',
    'test/verb_test.rb'
  ]
  
  s.has_rdoc = true
  s.homepage = 'http://github.com/gcnovus/grammar'
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Grammar RDoc', '--charset', 'utf-8']
  s.require_paths = ['lib']
  s.rubygems_version = '1.1.1'
end
require File.join(File.dirname(__FILE__), 'test_helper')
require 'grammar/ext/string'

class VerbTest < Test::Unit::TestCase

  def assert_equal_with_to_s(a, b, msg = nil)
    assert_equal_without_to_s(a.to_s, b.to_s, msg)
  end

  alias_method_chain :assert_equal, :to_s

  def test_first_singular
    assert_equal 'am', 'is'.first_person_singular
  end

  def test_second_singular
    assert_equal 'are', 'is'.second_person_singular
  end

  def test_third_singular
    assert_equal 'Is', 'Are'.third_person_singular
  end

  def test_first_plural
    assert_equal 'Are', 'Is'.first_person_plural
  end

  def test_second_plural
    assert_equal 'are', 'is'.second_person_plural
  end

  def test_third_plural
    assert_equal 'Are', 'Is'.third_person_plural
  end

end


require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # Relationships:
  #
  # A -> B -> C
  #      |
  #      `--> D
  def setup
    @a = make_page('A')
    @b = make_page('B')
    @c = make_page('C')
    @d = make_page('D')

    link(@a, @b)
    link(@b, @c)
    link(@b, @d)
  end

  def test_page_linking
    assert_equal [@b],     @a.child_pages
    assert_equal [@c, @d], @b.child_pages
    assert_equal [],       @c.child_pages
    assert_equal [],       @d.child_pages

    assert_equal [],   @a.parent_pages
    assert_equal [@a], @b.parent_pages
    assert_equal [@b], @c.parent_pages
    assert_equal [@b], @d.parent_pages
  end

  def test_page_tree
    assert_equal [@c, @d, @b, @a], @a.page_tree
    assert_equal [@c, @d, @b], @b.page_tree
    assert_equal [@c], @c.page_tree
  end

  def make_page(url)
    page = Page.new
    page.url = url
    page.save
    page
  end

  def link(parent, child)
    link = Link.new
    link.parent_page = parent
    link.child_page = child
    link.save
  end
end

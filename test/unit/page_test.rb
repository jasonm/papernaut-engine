require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def test_has_many_discussions
    page = create(:page)
    discussion = create(:discussion, content_page: page)
    assert_equal [discussion], page.reload.discussions
  end
end

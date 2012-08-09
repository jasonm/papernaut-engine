require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "has many discussions through links" do
    page = create(:page)
    discussion1 = create(:discussion)
    discussion2 = create(:discussion)

    create(:link, page: page, discussion: discussion1)
    create(:link, page: page, discussion: discussion2)

    assert_equal [discussion1, discussion2], page.reload.discussions
  end
end

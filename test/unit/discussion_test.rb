require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  test "finding by identifier" do
    page = create(:page)
    create(:identifier, page: page, body: "PREFIX:the-paper")
    discussion = create(:discussion, content_page: page)

    assert_equal [discussion], Discussion.identified_by('the-paper')
    assert_equal [], Discussion.identified_by('nothing')
  end

  test "finding multiple discussions by identifier" do
    page = create(:page)
    create(:identifier, page: page, body: "PREFIX:the-paper")
    discussion = create(:discussion, content_page: page)
    discussion2 = create(:discussion, content_page: page)

    page2 = create(:page)
    create(:identifier, page: page2, body: "PREFIX:the-paper")
    discussion3 = create(:discussion, content_page: page2)

    assert_equal [discussion, discussion2, discussion3], Discussion.identified_by('the-paper')
  end
end

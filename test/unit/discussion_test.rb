require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  test "has many pages through links" do
    discussion = create(:discussion)
    page1 = create(:page)
    page2 = create(:page)

    create(:link, discussion: discussion, page: page1)
    create(:link, discussion: discussion, page: page2)

    discussion.reload

    assert_equal 2, discussion.links.count
    assert_equal [page1, page2], discussion.pages
  end

  test "finding by identifier" do
    page = create(:page)
    create(:identifier, page: page, body: "PREFIX:the-paper")
    discussion = create(:discussion, pages: [page])

    assert_equal [discussion], Discussion.identified_by('the-paper')
    assert_equal [], Discussion.identified_by('nothing')
  end

  test "finding multiple discussions by identifier" do
    page = create(:page)
    create(:identifier, page: page, body: "PREFIX:the-paper")
    discussion1 = create(:discussion, pages: [page])
    discussion2 = create(:discussion, pages: [page])

    page2 = create(:page)
    create(:identifier, page: page2, body: "PREFIX:the-paper")
    discussion3 = create(:discussion, pages: [page2])

    assert_equal [discussion1, discussion2, discussion3], Discussion.identified_by('the-paper')
  end

  test "finding a discussion my multiple identifiers" do
    page1 = create(:page)
    create(:identifier, page: page1, body: "PREFIX:paper1A")
    create(:identifier, page: page1, body: "PREFIX:paper1B")

    page2 = create(:page)
    create(:identifier, page: page2, body: "PREFIX:paper2A")
    create(:identifier, page: page2, body: "PREFIX:paper2B")

    discussion = create(:discussion, pages: [page1, page2])

    assert_equal [discussion], Discussion.identified_by('paper1A')
    assert_equal [discussion], Discussion.identified_by('paper1B')
    assert_equal [discussion], Discussion.identified_by('paper2A')
    assert_equal [discussion], Discussion.identified_by('paper2B')
  end
end

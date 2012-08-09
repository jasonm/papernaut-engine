require 'test_helper'

class RedditRssLoaderTest < ActionDispatch::IntegrationTest
  test "respects the per page limit" do
    VCR.use_cassette('reddit-r-science') do
      max_pages = 3
      per_page = 5
      expected_items = per_page * max_pages

      Loaders::RedditRssLoader.new('science', max_pages, per_page).load

      assert_equal (per_page*max_pages), Discussion.count
      assert_equal (per_page*max_pages), Page.count
    end
  end
end

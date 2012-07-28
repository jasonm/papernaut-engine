require 'test_helper'

class ResolveDiscussionTest < ActionDispatch::IntegrationTest
  def test_submitting_discussion
    VCR.use_cassette('reddit-xaj1v') do
      reddit_url = 'http://www.reddit.com/r/science/comments/xaj1v/newly_discovered_scaffold_supports_turning_pain/'
      content_url = 'http://www.hopkinsmedicine.org/news/media/releases/newly_discovered_scaffold_supports_turning_pain_off'

      assert_equal 0, Discussion.count

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      assert_equal 1, Discussion.count
      assert_equal reddit_url, Discussion.first.url
      assert_equal content_url, Discussion.first.content_url
    end
  end
end

require 'test_helper'

class ResolveDiscussionTest < ActionDispatch::IntegrationTest
  def test_scraping_basic_discussion
    blog_url = 'http://news.sciencemag.org/sciencenow/2012/03/examining-his-own-body-stanford-.html'

    VCR.use_cassette('sciencemag-blog') do
      assert_equal 0, Discussion.count

      post '/discussions', :url => blog_url
      assert_equal 201, status

      assert_equal 1, Discussion.count
      assert_equal blog_url, Discussion.first.url
      assert_equal blog_url, Discussion.first.content_url
    end
  end

  def test_scraping_reddit_discussion
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

  def test_doi_identification_of_directly_linked_content
    VCR.use_cassette('reddit-x994l-westerners') do
      reddit_url = 'http://www.reddit.com/r/science/comments/x994l/westerners_burn_as_many_calories_as/'
      content_url = 'http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0040503'

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      assert_equal 1, Discussion.count
      assert_equal reddit_url, Discussion.first.url
      assert_equal content_url, Discussion.first.content_url
      assert_equal 'doi:10.1371/journal.pone.0040503', Discussion.first.identifier
    end
  end
end

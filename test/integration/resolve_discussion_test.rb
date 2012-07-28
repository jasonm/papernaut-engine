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
    VCR.use_cassette('reddit-x8olx-coverage') do
      reddit_url = 'http://www.reddit.com/r/science/comments/x8olx/for_the_first_time_we_are_getting_high_coverage/'
      content_url = 'http://www.cell.com/retrieve/pii/S0092867412008318'

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      assert_equal 1, Discussion.count
      assert_equal reddit_url, Discussion.first.url
      assert_equal content_url, Discussion.first.content_url
      assert_equal 'doi:10.1016/j.cell.2012.07.009', Discussion.first.identifier
    end
  end

end

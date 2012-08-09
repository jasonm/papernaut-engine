require 'test_helper'

class ResolveDiscussionTest < ActionDispatch::IntegrationTest
  def test_scraping_basic_discussion
    blog_url = 'http://news.sciencemag.org/sciencenow/2012/03/examining-his-own-body-stanford-.html'

    VCR.use_cassette('sciencemag-blog') do
      assert_equal 0, Discussion.count

      post '/discussions', :url => blog_url
      assert_equal 201, status

      discussion = Discussion.first
      assert_equal blog_url, discussion.url
      assert_equal [blog_url], discussion.page_urls
      assert_equal [], discussion.identifier_strings
    end
  end

  def test_scraping_reddit_discussion
    VCR.use_cassette('reddit-xaj1v-scaffold') do
      reddit_url = 'http://www.reddit.com/r/science/comments/xaj1v/newly_discovered_scaffold_supports_turning_pain/'
      content_url = 'http://www.hopkinsmedicine.org/news/media/releases/newly_discovered_scaffold_supports_turning_pain_off'

      assert_equal 0, Discussion.count

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      discussion = Discussion.first
      assert_equal reddit_url, discussion.url
      assert_equal [content_url], discussion.page_urls
      assert_equal [], discussion.identifier_strings
    end
  end

  def test_doi_identification_of_directly_linked_content
    VCR.use_cassette('reddit-x8olx-coverage') do
      reddit_url = 'http://www.reddit.com/r/science/comments/x8olx/for_the_first_time_we_are_getting_high_coverage/'
      content_url = 'http://www.cell.com/retrieve/pii/S0092867412008318'

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      discussion = Discussion.first
      assert_equal reddit_url, discussion.url
      assert_equal [content_url], discussion.page_urls
      assert_equal ['DOI:10.1016/j.cell.2012.07.009',
                    'ISSN:0092-8674',
                    'URL:http://www.cell.com/abstract/S0092-8674(12)00831-8'].sort,
                   discussion.identifier_strings.sort
    end
  end

  def test_arxiv_identification_of_directly_linked_content
    VCR.use_cassette('reddit-xajlk-silicene') do
      reddit_url = 'http://www.reddit.com/r/science/comments/xajlk/silicene_on_crystalline_silver_a_silicon_analogue/'
      content_url = 'http://arxiv.org/abs/1206.6246'

      post '/discussions', :url => reddit_url
      assert_equal 201, status

      discussion = Discussion.first
      assert_equal reddit_url, discussion.url
      assert_equal [content_url], discussion.page_urls
      assert_equal ['URL:http://arxiv.org/abs/1206.6246'], discussion.identifier_strings
    end
  end

  def test_pmid_and_pmcid_identification
    VCR.use_cassette('ncbi-PMC2377243') do
      url = 'http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2377243/'

      post '/discussions', :url => url

      discussion = Discussion.first
      assert_equal ['DOI:10.1186/1465-9921-9-37',
                    'ISSN:1465-9921',
                    'URL:http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2377243/',
                    'PMID:18439301',
                    'PMCID:PMC2377243'].sort,
                    discussion.identifier_strings.sort
    end
  end

  # TODO: test 1-level deep spidering eg http://www.bbc.co.uk/news/science-environment-19069560 -> http://www.pnas.org/content/early/2012/07/23/1204213109.abstract?sid=966d5de8-cc5f-452d-8abc-d5fd2d4ac607
end

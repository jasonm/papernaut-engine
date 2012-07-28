require 'nokogiri'
require 'open-uri'

class DiscussionScraper
  def self.discussion_for_url(url)
    new(url).discussion
  end

  def initialize(url)
    @url = url
  end

  def discussion
    existing_discussion || scrape_new_discussion
  end

  private

  def existing_discussion
    Discussion.find_by_url(@url)
  end

  def scrape_new_discussion
    discussion = scraper.scrape(@url)
    discussion.save
    discussion
  end

  def scraper
    scrapers.detect { |matcher, callable| callable if matcher.match(@url) }
  end

  def scrapers
    [
      [/reddit.com/, RedditScraper],
      [//, BasicScraper]
    ]
  end

  class BasicScraper
    def self.scrape(url)
      new(url).discussion
    end

    def initialize(url)
      @url = url
    end

    def discussion
      discussion = Discussion.new
      discussion.url = discussion_url
      discussion.content_url = content_url
      discussion
    end

    def discussion_url
      @url
    end

    def content_url
      @url
    end
  end

  class RedditScraper < BasicScraper
    def content_url
      # http://www.reddit.com/r/science/comments/xaj1v/newly_discovered_scaffold_supports_turning_pain/
      html = open(@url).read
      doc = Nokogiri::HTML(html)
      content_url = doc.css("#siteTable a.title")[0]['href']
    end
  end
end

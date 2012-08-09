require 'nokogiri'
require 'open-uri' #TODO: change to curb for moar speed and stuff

class DiscussionScraper
  def self.discussion_for_url(url)
    new(url).discussion
  end

  def initialize(url)
    @url = url
  end

  # TODO: remove #existing_discussion as well as the #save in scrape_new_discussion to eliminate I/O?
  # have to move the ||-logic up
  def discussion
    existing_discussion || scrape_new_discussion
  end

  private

  def existing_discussion
    Discussion.find_by_url(@url)
  end

  def scrape_new_discussion
    scraper_class.new(@url).discussion.tap(&:save)
  end

  def scraper_class
    scraper_classes.each do |matcher, scraper_class|
      return scraper_class if matcher.match(@url)
    end
  end

  def scraper_classes
    [
      [/reddit.com/, RedditScraper],
      [//, BaseScraper]
    ]
  end
end

class BaseScraper
  def self.scrape(url)
    new(url).discussion
  end

  attr_reader :discussion

  def initialize(url)
    @url = url
    build_discussion
  end

  private

  def build_discussion
    @discussion = Discussion.new
    @discussion.url = discussion_url
    @discussion.pages = [Page.find_or_create_by_url(content_url)]
  end

  def discussion_url
    @url
  end

  def content_url
    @url
  end
end

class RedditScraper < BaseScraper
  def content_url
    # http://www.reddit.com/r/science/comments/xaj1v/newly_discovered_scaffold_supports_turning_pain/
    html = open(@url).read
    doc = Nokogiri::HTML(html)
    content_url = doc.css("#siteTable a.title")[0]['href']
  end
end

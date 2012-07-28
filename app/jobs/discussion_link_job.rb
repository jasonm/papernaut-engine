class DiscussionLinkJob
  def self.work(url)
    self.new(url).work
  end

  def initialize(url)
    @url = url
  end

  def work
    discussion = DiscussionScraper.discussion_for_url(@url)
    discussion.link
  end
end

# TODO: Refactor to separate loading from identification: load with Page#identified_at nil.  Then, identify separately.  IdentifyDiscussionJob shouldnt have to create the discussion.
class IdentifyDiscussionJob
  def initialize(discussion_url, discussion_title, page_urls)
    @discussion_url = discussion_url
    @discussion_title = discussion_title
    @page_urls = page_urls
  end

  def work
    discussion = Discussion.find_or_create_by_url(@discussion_url)
    discussion.title = @discussion_title
    discussion.pages = pages
    discussion.save!

    identify_pages_in_background
  end

  private

  def identify_pages_in_background
    pages.each(&:identify)
  end

  def pages
    @page_urls.map { |url| Page.find_by_url(url) || Page.new(url: url) }
  end
end

class IdentifyDiscussionJob
  def initialize(discussion_url, page_urls)
    @discussion_url = discussion_url
    @page_urls = page_urls
  end

  def work
    discussion = Discussion.find_or_create_by_url(@discussion_url)
    discussion.pages = pages
    discussion.save!

    pages.each do |page|
      Thread.new do
        begin
          page.identify
        ensure
          ActiveRecord::Base.connection.close
        end
      end
    end
  end

  private

  def pages
    @page_urls.map { |url| Page.find_by_url(url) || Page.new(url: url) }
  end
end

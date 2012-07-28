class Discussion < ActiveRecord::Base
  has_many :links
  has_many :pages, through: :links

  def link
    spider
    identify_linked_pages
    identify

    save!
  end

  private

  def spider
    # self.links = Spider.links_for_url(@discussion.subject_url)
    content_page = Page.find_or_create_by_url(content_url)
    content_link = Link.find_or_create_by_discussion_id_and_page_id(self.id, content_page.id)

    self.links = [content_link]
  end

  def identify_linked_pages
    pages.each(&:identify)
  end

  def identify
    # identifier = DiscussionIdentifierCalculator.identifier_for_discussion(@discussion)
    self.identifier = pages.first.identifier
  end
end

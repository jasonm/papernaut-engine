class Discussion < ActiveRecord::Base
  belongs_to :content_page, class_name: "Page"
  # Eventually, Discussion has kind (blog/hn/reddit/nyt/etc), #/comments, author, activity, etc.

  def link
    spider
    identify_linked_pages
  end

  def identifier_strings
    content_page.identifiers.map(&:body)
  end

  def content_url
    content_page.url
  end

  private

  def spider
    # noop
  end

  def identify_linked_pages
    content_page.page_tree.each(&:identify)
  end
end

class Discussion < ActiveRecord::Base
  has_many :links
  has_many :pages, through: :links
  has_many :identifiers, through: :pages

  # Eventually, Discussion has kind (blog/hn/reddit/nyt/etc), #/comments, author, activity, etc., for display

  def link
    identify_linked_pages
  end

  def identifier_strings
    identifiers.map(&:body)
  end

  def page_urls
    pages.map(&:url)
  end

  def self.identified_by(identifier_substring)
    joins(pages: :identifiers).where("identifiers.body LIKE ?", "%#{identifier_substring}%")
  end

  private

  def identify_linked_pages
    pages.each(&:identify)
  end
end

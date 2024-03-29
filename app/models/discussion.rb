class Discussion < ActiveRecord::Base
  has_many :links
  has_many :pages, through: :links
  has_many :identifiers, through: :pages

  attr_accessible :url, :title, :pages, :page_urls

  # Eventually, Discussion has title, kind (blog/hn/reddit/nyt/etc), #/comments, author, activity, etc., for display

  def self.load(attrs)
    if existing = find_by_url(attrs[:url])
      existing.update_attributes(attrs)
    else
      create(attrs)
    end
  end

  def link
    identify_linked_pages
  end

  def identifier_strings
    identifiers.map(&:body)
  end

  def page_urls
    pages.map(&:url)
  end

  def page_urls=(new_urls)
    self.pages = new_urls.map { |url| Page.find_by_url(url) || Page.new(url: url) }
  end

  def self.identified_by(identifier_substring)
    joins(pages: :identifiers).where("identifiers.body LIKE ?", "%#{identifier_substring}%")
  end

  private

  def identify_linked_pages
    pages.each(&:identify)
  end
end

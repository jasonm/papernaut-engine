class Page < ActiveRecord::Base
  cattr_accessor :identifier_service

  has_many :discussions, inverse_of: :content_page
  has_many :identifiers

  has_many :parent_links, :foreign_key => :child_page_id, :class_name => 'Link'
  has_many :child_links, :foreign_key => :parent_page_id, :class_name => 'Link'

  has_many :parent_pages, :through => :parent_links
  has_many :child_pages, :through => :child_links

  attr_accessible :url

  def identify
    self.identifiers = identifier_service.identifiers(url)
    save!
  end

  def page_tree
    [child_pages.map(&:page_tree), self].flatten
  end
end

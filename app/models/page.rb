class Page < ActiveRecord::Base
  cattr_accessor :identifier_service

  # TODO: doesn't seem to work
  # 1.9.3p194 :015 > Page.find(99).discussions.count
  #   Page Load (0.5ms)  SELECT "pages".* FROM "pages" WHERE "pages"."id" = $1 LIMIT 1  [["id", 99]]
  #    (34.3ms)  SELECT COUNT(*) FROM "discussions" WHERE "discussions"."page_id" = 99
  # ActiveRecord::StatementInvalid: PG::Error: ERROR:  column discussions.page_id does not exist
  # LINE 1: SELECT COUNT(*) FROM "discussions"  WHERE "discussions"."pag...
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

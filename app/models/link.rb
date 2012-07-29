class Link < ActiveRecord::Base
  belongs_to :parent_page, foreign_key: :parent_page_id, class_name: 'Page'
  belongs_to :child_page, foreign_key: :child_page_id, class_name: 'Page'

  attr_accessible :parent_page, :child_page
end

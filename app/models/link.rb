class Link < ActiveRecord::Base
  belongs_to :page
  belongs_to :discussion
end

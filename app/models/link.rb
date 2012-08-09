class Link < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :page
end

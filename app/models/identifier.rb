class Identifier < ActiveRecord::Base
  attr_accessible :body

  belongs_to :page
end

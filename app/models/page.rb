class Page < ActiveRecord::Base
  cattr_accessor :identifier_service

  has_many :links
  has_many :discussions, through: :links

  has_many :identifiers

  attr_accessible :url

  def identify
    self.identifiers = identifier_service.identifiers(url)
    save!
  end
end

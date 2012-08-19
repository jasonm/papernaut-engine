class Page < ActiveRecord::Base
  cattr_accessor :identifier_service

  has_many :links
  has_many :discussions, through: :links

  has_many :identifiers

  attr_accessible :url

  def identify
    self.identifiers = identifier_service.identifiers(url)
    self.identified_at = Time.now
    save!
  end

  # Page.unidentified.each(&:identify) will identify all new Pages sequentially
  def self.unidentified
    where('identified_at IS NULL')
  end

  def self.with_no_identifiers
    joins("LEFT OUTER JOIN identifiers ON identifiers.page_id = pages.id").where("identifiers.page_id IS NULL")
  end
end

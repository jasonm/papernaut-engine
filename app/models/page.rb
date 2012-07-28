class Page < ActiveRecord::Base
  cattr_accessor :identifier_service

  has_many :links
  has_many :discussions, through: :links

  def identify
    # linked_pages.each(&:identify!)
    # linked_pages.each do |page|
      # page.identifier = IdentifierFinder.identifier_for_page(page)
      # page.save!
    # end

    self.identifier = identifier_service.identify(url)
    save!
  end
end

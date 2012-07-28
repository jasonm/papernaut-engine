class Page < ActiveRecord::Base
  has_many :links
  has_many :discussions, through: :links

  def identify
    self.identifier = 'doi:whatevs'
    save!
  end
end

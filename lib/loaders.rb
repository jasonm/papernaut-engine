module Loaders
  mattr_accessor :logger
  self.logger = Rails.logger

  USER_AGENT = 'JournalClub by jason.p.morrison@gmail.com'
end

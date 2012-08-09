module Loaders
  mattr_accessor :logger
  self.logger = Rails.logger
end

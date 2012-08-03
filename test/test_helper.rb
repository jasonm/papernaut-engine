ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('test/vcr_cassettes')
  c.hook_into :webmock
end

class ActiveSupport::TestCase
  #TODO: Remove fixtures
  fixtures :all

  include FactoryGirl::Syntax::Methods
end

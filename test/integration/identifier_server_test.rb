require 'test_helper'

class IdentifierServerTest < ActionDispatch::IntegrationTest
  test "single correct identification" do
    url = 'http://stm.sciencemag.org/content/4/145/145ra105'

    expected_identifiers = [
      'DOI:10.1126/scitranslmed.3004145',
      'URL:http://stm.sciencemag.org/content/4/145/145ra105']

    page = create(:page, url: url)

    VCR.use_cassette("identify-#{url}") do
      page.identify
    end

    assert_equal expected_identifiers.sort, page.identifiers.map(&:body).sort
  end
end

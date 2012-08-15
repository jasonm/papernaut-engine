require 'test_helper'

class IdentifierServerTest < ActionDispatch::IntegrationTest
  test "single correct identification" do
    url = 'http://stm.sciencemag.org/content/4/145/145ra105'

    expected = [
      'DOI:10.1126/scitranslmed.3004145',
      'URL:http://stm.sciencemag.org/content/4/145/145ra105']

    assert_equal expected.sort, request_identifiers(url).sort
  end

  test "item with multiple identifications" do
    url = 'http://ehp03.niehs.nih.gov/article/info%3Adoi%2F10.1289%2Fehp.120-a305'

    expected = [
      'DOI:10.1289/ehp.120-a305',
      'URL:http://www.ehponline.org/ambra-doi-resolver/10.1289/ehp.120-a305',
      'DOI:10.2166/washdev.2012.043',
      'URL:http://www.iwaponline.com/washdev/002/washdev0020087.htm']

    assert_equal expected.sort, request_identifiers(url).sort

    # TODO: Handle HTTP 300 Multiple Choices:
    #
    #     #
    # gives response from translation server
    #
    # zotero(5)(+0000001): HTTP/1.0 300 Multiple Choices
    # Content-Type: application/json
    # {"10.1289/ehp.120-a305":"Purifying Drinking Water with Sun, Salt, and Limes","10.2166/washdev.2012.043":"Optimizing the solar water disinfection (SODIS) method by decreasing turbidity with NaCl"}
  end

  def request_identifiers(url)
    page = create(:page, url: url)

    VCR.use_cassette("identify-#{url}") do
      page.identify
    end

    page.identifiers.map(&:body)
  end
end

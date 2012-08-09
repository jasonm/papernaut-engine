require 'test_helper'

class QueryForDiscussionsTest < ActionDispatch::IntegrationTest
  def test_querying_for_nonexistent_identifier
    get '/discussions.json', { query: 'does-not-exist' }
    assert_equal 200, status
    assert_equal [].to_json, response.body
  end

  def test_querying_for_single_identifier
    page = create(:page)
    discussion = create(:discussion, pages: [page])
    identifier = create(:identifier, page: page, body: "PREFIX:the-paper")

    get '/discussions.json', { query: 'the-paper' }
    assert_equal 200, status
    assert_equal [discussion].to_json, response.body
  end
end

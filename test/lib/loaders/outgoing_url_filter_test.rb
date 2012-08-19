require 'test_helper'

class Loaders::OutgoingUrlFilterTest < ActiveSupport::TestCase
  test 'disallows URLs with the same domain as the root URL' do
    root_url = 'http://bloggytown.com/page/1'
    candidate_urls = %w(http://bloggytown.com/about http://bloggytown.com/terms)

    assert_equal [], Loaders::OutgoingUrlFilter.new(root_url, candidate_urls).filtered
  end

  test 'allows legit URLs' do
    root_url = 'http://bloggytown.com/page/1'
    candidate_urls = %w(http://arxiv.org/1 https://dx.doi.org/1)

    assert_equal candidate_urls, Loaders::OutgoingUrlFilter.new(root_url, candidate_urls).filtered
  end

  test 'disallows URLs to excluded domains' do
    root_url = 'http://whatever.com'

    allowed = %w(http://arxiv.org/123)
    disallowed = %w(http://twitter.com/person http://wikipedia.org/article)
    candidate_urls = allowed + disallowed

    assert_equal allowed, Loaders::OutgoingUrlFilter.new(root_url, candidate_urls).filtered
  end

  test 'disallows URLs with non http/https schemes' do
    root_url = 'http://whatever.com'
    candidate_urls = %w(mailto:email@domain.com javascript:doFancyStuff ftp://dumpsite.com/1.pdf)

    assert_equal [], Loaders::OutgoingUrlFilter.new(root_url, candidate_urls).filtered
  end
end

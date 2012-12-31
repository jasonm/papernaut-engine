require 'addressable/uri'

module Loaders
  class OutgoingUrlFilter
    EXCLUDED_DOMAINS = %w(
      twitter.com
      facebook.com
      addthis.com
      youtube.com
      wikipedia.org
      qualtrics.com
    )

    def initialize(root_url, candidate_urls)
      @root_url = root_url.to_s
      @candidate_urls = candidate_urls.map(&:to_s)
    end

    def filtered
      @candidate_urls.reject { |url| exclude?(url) }
    end

    private

    def exclude?(url)
      same_domain?(@root_url, url) ||
        excluded_domain?(url) ||
        excluded_scheme?(url)
    end

    def same_domain?(url1, url2)
      domain_for(url1) == domain_for(url2)
    end

    def excluded_domain?(url)
      return false if domain_for(url).nil?

      EXCLUDED_DOMAINS.any? { |excluded_domain|
        domain_for(url).include?(excluded_domain)
      }
    end

    def excluded_scheme?(url)
      allowed_schemes = %w(http https)
      allowed_schemes.exclude?(scheme_for(url))
    end

    def domain_for(url)
      Addressable::URI.parse(url).try(:host)
    end

    def scheme_for(url)
      Addressable::URI.parse(url).try(:scheme)
    end
  end
end

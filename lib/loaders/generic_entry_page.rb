require 'loaders/title_matchers'
require 'digest'

module Loaders
  class GenericEntryPage < Loaders::Base::EntryPage
    <<-USAGE
    url = "http://blog.chron.com/sciguy/2012/02/health-officials-tax-and-regulate-sugar-like-tobacco/"
    l = Loaders::GenericEntryPage.new(url)
    l.title
    l.send(:page_urls)
    USAGE

    def title
      doc.css(*Loaders::TITLE_MATCHERS).first.text
    end

    def unfiltered_page_urls
      doc.css('a').map { |a| a['href'] }.select { |href| crossref_domain?(href) }
    end

    def crossref_domain?(url)
      if domain = Addressable::URI.parse(url.to_s).try(:host)
        domain_hash = Digest::SHA256.hexdigest(domain)
        crossref_url_hashes.index(domain_hash)
      end
    end

    def crossref_url_hashes
      domains_filename = File.join(File.dirname(__FILE__), "crossref-domains.txt")
      @crossref_url_hashes ||= File.open(domains_filename).read.split
    end
  end
end

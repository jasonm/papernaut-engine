module Loaders
  module SciAm
    # Usage:
    """
    (0..7000).step(30).each { |offset| Loaders::SciAm::WebArchiveLoader.new(offset).load }
    """

    class WebArchiveLoader
      POLITE_REQUEST_INTERVAL_SECONDS = 2

      # Pages contain 30 entries.  Content exists until offset 6900 or so as of 19-Aug-2012.
      def initialize(offset)
        @offset = offset
      end

      def load
        entry_urls.each do |entry_url|
          EntryPage.new(entry_url).load
          sleep POLITE_REQUEST_INTERVAL_SECONDS
        end
      end

      private

      def entry_urls
        page_doc.css('a#blogTextLink').map { |a| a['href'] }
      end

      def page_doc
        @page_doc ||= fetch_and_parse(page_url)
      end

      def page_url
        "http://blogs.scientificamerican.com/home2.php?offset_n=#{@offset}"
      end

      # TODO: extract up
      def fetch_and_parse(url)
        Loaders.logger.debug("#{self.class.name} fetching #{url}")

        body = Curl.get(url) do |http|
          http.headers['User-Agent'] = USER_AGENT
        end.body_str

        Nokogiri::HTML.parse(body)
      end
    end

    class EntryPage < Loaders::Base::EntryPage
      private

      def title_tag_selector
        'h1#postTitle2 a'
      end

      def page_links_selector
        '#singleBlogPost a'
      end
    end
  end
end

require 'addressable/uri'

module Loaders

  # Example usage:
  """
  loader = Loaders::Plos::WebArchiveLoader.new(max_pages = 3)
  loader.load
  """
  module Plos
    class WebArchiveLoader
      DEFAULT_MAX_PAGES = 1
      DEFAULT_STARTING_PAGE = 1

      def initialize(max_pages = DEFAULT_MAX_PAGES, starting_page = DEFAULT_STARTING_PAGE)
        @max_pages = max_pages
        @starting_page = starting_page
      end

      def load
        page_number = @starting_page
        until page_number == @max_pages
          url = url_for_page(page_number)
          page = Loaders::Plos::WebArchivePage.new(url)

          return if page.empty?

          page.load
          page_number += 1
        end
      end

      private

      def url_for_page(page_number)
        "http://blogs.plos.org/page/#{page_number}"
      end
    end

    class WebArchivePage
      EMPTY_PAGE_MESSAGE = "the page you requested could not be found."

      def initialize(url)
        @url = url
      end

      def load
        entry_urls.each do |entry_url|
          Loaders::Plos::EntryPage.new(entry_url).load
        end
      end

      def empty?
        if doc.text.include?(EMPTY_PAGE_MESSAGE)
          Loaders.logger.warn("#{self.class.name} encountered empty page at #{@url}")
          true
        end
      end

      private

      def entry_urls
        doc.css(entries_selector).map { |a| a['href'] }
      end

      def entries_selector
        'h2.entry-title a'
      end

      def doc
        @doc ||= Loaders.get_html(@url)
      end
    end

    class EntryPage < Loaders::Base::EntryPage
      private

      def title_tag_selector
        'h1.entry-title'
      end

      def page_links_selector
        'div.entry-content a'
      end
    end
  end
end

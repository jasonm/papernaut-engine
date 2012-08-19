require 'addressable/uri'

module Loaders

  # Example usage:
  """
  blog_urls = Loaders::DiscoverMagazine::Index.new.blog_urls
  blog_url = blog_urls.first
  loader = Loaders::DiscoverMagazine::WebArchiveLoader.new(blog_url, max_pages = 3)
  loader.load
  """
  module DiscoverMagazine
    class Index
      def blog_urls
        doc = Loaders.get_html('http://blogs.discovermagazine.com/')
        doc.css('h2.sumtitle a').map { |a| a['href'] }
      end
    end

    class WebArchiveLoader
      DEFAULT_MAX_PAGES = 1
      EMPTY_PAGE_MESSAGE = "Sorry, but you are looking for something that isn't here."

      def initialize(blog_url, max_pages = DEFAULT_MAX_PAGES, starting_page = 1)
        raise "Must specify a DiscoverMagazine blog root URL" if blog_url.nil?

        @blog_url = blog_url
        @max_pages = max_pages
        @starting_page = starting_page
      end

      def load
        each_page do |page_doc|
          entry_urls(page_doc).each do |entry_url|
            EntryPage.new(entry_url).load
          end
        end
      end

      private

      def each_page
        page_number = @starting_page

        loop do
          page_doc = Loaders.get_html(url_for_page(page_number))
          if page_doc.text.include?(EMPTY_PAGE_MESSAGE)
            Loaders.logger.warn("#{self.class.name} encountered empty page at #{url_for_page(page_number)}")
            break
          end

          yield page_doc

          break if page_number == @max_pages
          page_number += 1
        end
      end

      def entry_urls(page_doc)
        page_doc.css('div.weblog-entry h2 a').map { |a| a['href'] }
      end

      def url_for_page(page_number)
        @blog_url + "/page/#{page_number}"
      end
    end

    class EntryPage < Loaders::Base::EntryPage
      private

      def title_tag_selector
        'div.weblog-entry h2 a'
      end

      def page_links_selector
        'div.weblog-entry div.entry a'
      end
    end
  end
end

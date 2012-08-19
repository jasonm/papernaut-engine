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

    class EntryPage # < Loaders::Base::BlogEntryPage
      def initialize(url)
        @url = url
      end

      # TODO: DRY up as template method of sorts? superclass method?
      def load
        begin
          Discussion.create(url: url, title: title, page_urls: page_urls)
        rescue Exception => e
          exception_presentation = "#{e.class} (#{e.message}):\n    " + e.backtrace.join("\n    ") + "\n\n"
          Loaders.logger.error("#{self.class.name} could not load #{@url}:\n#{exception_presentation}")
        end
      end

      private

      def url
        @url
      end

      def title
        doc.css(title_tag_selector)[0].text
      end

      def page_urls
        filtered_page_urls
      end

      def filtered_page_urls
        Loaders::OutgoingUrlFilter.new(@url, unfiltered_page_urls).filtered
      end

      def unfiltered_page_urls
        doc.css(page_links_selector).map { |a| a['href'] }
      end

      def doc
        @doc ||= Loaders.get_html(url)
      end

      def title_tag_selector
        'div.weblog-entry h2 a'
      end

      def page_links_selector
        'div.weblog-entry div.entry a'
      end
    end
  end
end

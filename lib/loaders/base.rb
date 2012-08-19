module Loaders
  module Base
    class EntryPage
      def initialize(url)
        @url = url
      end

      def load
        begin
          Discussion.create(url: url, title: title, page_urls: page_urls)
        rescue Exception => e
          exception_presentation = "#{e.class} (#{e.message}):\n    " + e.backtrace.join("\n    ") + "\n\n"
          Loaders.logger.error("#{self.class.name} could not load #{url}:\n#{exception_presentation}")
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
        Loaders::OutgoingUrlFilter.new(url, unfiltered_page_urls).filtered
      end

      def unfiltered_page_urls
        doc.css(page_links_selector).map { |a| a['href'] }.compact
      end

      def doc
        @doc ||= Loaders.get_html(url)
      end

      def title_tag_selector
        raise "#{self.class.name} must implement #title_tag_selector"
      end

      def page_links_selector
        raise "#{self.class.name} must implement #page_links_selector"
      end
    end
  end
end

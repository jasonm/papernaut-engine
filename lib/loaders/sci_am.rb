module Loaders
  module SciAm
    class WebArchiveLoader
      POLITE_REQUEST_INTERVAL_SECONDS = 2

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

    class EntryPage
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
        doc.css('h1#postTitle2 a')[0].text
      end

      def page_urls
        Loaders::OutgoingUrlFilter.new(@url, unfiltered_urls).filtered
      end

      def unfiltered_urls
        doc.css('#singleBlogPost a').map { |a| a['href'] }
      end

      def doc
        @doc ||= fetch_and_parse(@url)
      end

      #TODO: DRY up #fetch_and_parse across classes
      def fetch_and_parse(url)
        Loaders.logger.debug("#{self.class.name} fetching #{url}")

        body = Curl.get(url) do |http|
          http.headers['User-Agent'] = Loaders::USER_AGENT
        end.body_str

        Nokogiri::HTML.parse(body)
      end
    end
  end
end

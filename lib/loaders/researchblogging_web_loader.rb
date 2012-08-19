module Loaders
  class ResearchbloggingWebLoader
    DEFAULT_MAX_PAGES = 2
    REQUEST_INTERVAL_IN_SECONDS = 2
    HOMEPAGE_URL = "http://researchblogging.org/"

    def initialize(max_pages = DEFAULT_MAX_PAGES)
      @max_pages = max_pages
    end

    def load
      each_page do |page_doc|
        each_post(page_doc) do |post_doc|
          load_post(post_doc)
        end
      end
    end

    def each_page
      page_number = 0
      url = HOMEPAGE_URL

      loop do
        page_number += 1
        page_doc = fetch_and_parse(url)
        yield page_doc
        url = next_page_url(page_doc)
        break if url.nil? || page_number == @max_pages
        sleep REQUEST_INTERVAL_IN_SECONDS
      end
    end

    def each_post(page_doc)
      page_doc.css('.articleContent').each do |post_doc|
        yield post_doc
      end
    end

    def load_post(post_doc)
      discussion_url = post_doc.css('h1 a')[0]['title']
      discussion_title = post_doc.css('h1 a')[0].text
      page_urls = post_doc.css('.articleBox a').map { |a| a['href'] }.uniq

      load_discussion_and_pages(discussion_url, discussion_title, page_urls)
    end

    private

    def next_page_url(page_doc)
      pagination_links = page_doc.css('#pageBrowser>ul>li>a')
      next_page_link = pagination_links.detect { |a| a.text =~ /Next/ }

      if next_page_link
        next_page_link['href']
      end
    end

    def fetch_and_parse(url)
      Loaders.logger.debug("#{self.class.name} fetching #{url}")
      html = Curl.get(url).body_str
      Nokogiri::HTML.parse(html)
    end

    def load_discussion_and_pages(discussion_url, discussion_title, page_urls)
      begin
        Loaders.logger.debug("Going to load discussion #{discussion_url} with #{page_urls.count} pages:\n    " + page_urls.join("\n    "))
        Discussion.load(url: discussion_url, title: discussion_url, page_urls: page_urls)
      rescue Exception => e
        exception_presentation = "#{e.class} (#{e.message}):\n    " + e.backtrace.join("\n    ") + "\n\n"
        Loaders.logger.error("#{self.class.name} could not load discussion #{discussion_url}:\n#{exception_presentation}")
      end
    end
  end
end

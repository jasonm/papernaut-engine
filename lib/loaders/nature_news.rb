# require 'feedzirra'

module Loaders
  # http://www.nature.com/news/
  #   e.g. http://www.nature.com/news/cancer-stem-cells-tracked-1.11087
  #   refs:
  #     'ol.references li a' -- maybe only first 'a' in the 'li' ?
  #     'ul#article-refrences li a' (SIC)
  #     'ul#article-refrences li' -- older ones may be missing link href? EG:
  #       * http://www.nature.com/news/2009/090130/full/news.2009.71.html
  #         "Burt, R. K. et al. Lancet Neurol. Advanced online publication doi:10.1016/S1474-4422(09)70017-1 (2009)."
  #   RSS http://feeds.nature.com/NatureNewsComment
  #     * links directly 

  module NatureNews
    USER_AGENT = 'JournalClub by jason.p.morrison@gmail.com'

    class WebLoader
      POLITE_REQUEST_INTERVAL_SECONDS = 2

      def initialize(year = '2012', month = '08')
        @year = year
        @month = month
      end

      def load
        each_page do |page|
          news_articles(page).each do |article_doc|
            entry_url = article_doc.css('h1 a')[0]['href']
            EntryPage.new(entry_url).load
          end
        end
      end

      private

      def each_page
        page_number = 1

        loop do
          page = fetch_and_parse(url_for_page(page_number))

          yield page

          next_page_link = page.css('.paging .next')[0]
          break if next_page_link.nil?
          sleep POLITE_REQUEST_INTERVAL_SECONDS
          page_number += 1
        end
      end

      def news_articles(page)
        page.css('article').select { |article_doc|
          is_news = article_doc.css('h2 span:contains("News")').any?
        }
      end

      def url_for_page(page_number)
        "http://www.nature.com/nature/archive/category.html?code=archive_news&year=#{@year}&month=#{@month}&page=#{page_number}"
      end

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
        'title'
      end

      def page_links_selector
        'ol.references li a, ul#article-refrences li a:contains("Article")'
      end
    end
  end
end

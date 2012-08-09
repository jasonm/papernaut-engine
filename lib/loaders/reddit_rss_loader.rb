require 'feedzirra'

module Loaders
  class RedditRssLoader
    DEFAULT_MAX_PAGES = 2
    DEFAULT_PER_PAGE = 5
    REDDIT_PREFIX_FOR_LINK = 't3_'
    REDDIT_POLITE_REQUEST_INTERVAL_SECONDS = 2

    def initialize(subreddit_name, max_pages = DEFAULT_MAX_PAGES, per_page = DEFAULT_PER_PAGE)
      @subreddit_name = subreddit_name
      @max_pages = max_pages
      @per_page = per_page
    end

    def load
      each_feed_page do |page|
        page.entries.each do |entry|
          RedditRssEntry.new(entry).load
        end
      end
    end

    def each_feed_page
      page_number = 0
      url = feed_url

      loop do
        page_number += 1
        feed_page = fetch_and_parse(url)
        yield feed_page
        url = next_page_url(feed_page)
        break if url.nil? || page_number == @max_pages
        sleep REDDIT_POLITE_REQUEST_INTERVAL_SECONDS
      end
    end

    private

    def next_page_url(feed)
      last_entry = feed.entries.last

      if last_entry
        last_entry.url =~ %r{/comments/([^/]*)/}
        last_reddit_item_identifier = $1
        feed_url(last_reddit_item_identifier)
      end
    end

    def fetch_and_parse(url)
      Loaders.logger.debug("RedditRssLoader fetching #{url}")

      # Can't use Feedzirra::Feed.fetch_and_parse directly because webmock can't fake Curb::Multi
      xml = Curl.get(url) do |http|
        http.headers['User-Agent'] = 'JournalClub RedditRssLoader by /u/jayunit'
      end.body_str

      Feedzirra::Feed.parse(xml)
    end

    def feed_url(after=nil)
      "http://www.reddit.com/r/#{@subreddit_name}.rss?limit=#{@per_page}&after=#{REDDIT_PREFIX_FOR_LINK}#{after}"
    end

    class RedditRssEntry
      def initialize(entry)
        @entry = entry
      end

      def load
        begin
          IdentifyDiscussionJob.new(discussion_url, [content_url]).work
        rescue Exception => e
          exception_presentation = "#{e.class} (#{e.message}):\n    " + e.backtrace.join("\n    ") + "\n\n"
          Loaders.logger.error("RedditRssLoader could not load discussion #{discussion_url}:\n#{exception_presentation}")
        end
      end

      private

      def discussion_url
        @entry.url
      end

      def content_url
        summary_links = Nokogiri::HTML.parse(@entry.summary).css('a')
        link_tag = summary_links.detect { |tag| tag.text == '[link]' }
        link_tag['href']
      end
    end
  end
end

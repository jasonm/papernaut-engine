#!/usr/bin/env /Users/jason/dev/zotero/journalclub/script/rails runner
#TODO: how to make that ^ path relative?

require 'feedzirra'

module Loaders
  class RedditRssLoader
    # def initialize(subreddit_name, limit=100, journal_club_api=LocalJournalClub.new)
    def initialize(journal_club_api, subreddit_name, limit = 3)
      @journal_club_api = journal_club_api
      @subreddit_name = subreddit_name
      @limit = limit
    end

    def load
      discussion_urls.each do |discussion_url|
        @journal_club_api.create_discussion(discussion_url)
      end
    end

    private

    def discussion_urls
      feed.entries.map(&:entry_id)
    end

    def feed
      @feed ||= Feedzirra::Feed.fetch_and_parse(feed_url, {
        user_agent: "JournalClub RedditRssLoader by /u/jayunit"
      })
    end

    def feed_url
      "http://www.reddit.com/r/#{@subreddit_name}.rss?limit=#{@limit}"
    end
  end

  def self.load_reddit_rss(subreddit_name)
    journal_club = LocalJournalClub.new
    loader = Loaders::RedditRssLoader.new(journal_club, subreddit_name, 100)
    loader.load
  end
end

# if __FILE__ == $0
#   journal_club = LocalJournalClub.new # RemoteJournalClub.new(ENV['JOURNAL_CLUB_URL'])
#   limit = 20
#   loader = Loaders::RedditRssLoader.new(journal_club, ENV['SUBREDDIT_NAME'], limit)
#   loader.load
# end
#
# url param &limit is maxed at 100 https://github.com/reddit/reddit/wiki/API
# So, to paginate:
# http://reddit.com/r/[subreddit].[rss/json]?limit=[limit]&after=[after]
# e.g. http://www.reddit.com/r/science/?count=25&after=t3_xw9wx

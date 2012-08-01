# Remote HTTP wrapper around JCAPI, for use by Loader and execution outside JCAPI process

require 'json'
require 'curb'

class RemoteJournalClub
  def initialize(root_url)
    @root_url = root_url
  end

  def create_discussion(url)
    json_post('discussions', { 'url' => url })
  end

  private

  def json_post(path, params)
    json = params.to_json
    url = URI.join(@root_url, path)

    # TODO: Something is buggy in here?
    # [master][~/dev/zotero/journalclub] JOURNAL_CLUB_URL=http://localhost:3000 SUBREDDIT_NAME=science be rails runner lib/loaders/reddit_rss_loader.rb
    # POST to http://localhost:3000/discussions with {"url":"http://www.reddit.com/r/science/comments/xhz2k/higgs_boson_results_from_lhc_get_even_stronger/"}
    # /Users/jason/.rvm/gems/ruby-1.9.3-p194/gems/curb-0.8.1/lib/curl/easy.rb:55:in `add': can't convert nil into String (TypeError)
    # 	from /Users/jason/.rvm/gems/ruby-1.9.3-p194/gems/curb-0.8.1/lib/curl/easy.rb:55:in `perform'

    puts "POSTing to #{url} with #{json}"

    Curl::Easy.http_post(url, json) do |curl|
      curl.headers["Content-Type"] = "application/json"
    end
  end
end

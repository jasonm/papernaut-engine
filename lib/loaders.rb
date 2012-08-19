module Loaders
  mattr_accessor :logger
  self.logger = Rails.logger

  USER_AGENT = 'JournalClub by jason.p.morrison@gmail.com'

  def self.get_html(url)
    Loaders.logger.debug("Loader fetching #{url}")

    body = Curl.get(url) do |http|
      http.headers['User-Agent'] = Loaders::USER_AGENT

      http.follow_location = true
      http.max_redirects = 3
      http.connect_timeout = 5
      http.timeout = 5
    end.body_str

    Nokogiri::HTML.parse(body)
  end
end

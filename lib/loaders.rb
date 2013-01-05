module Loaders
  mattr_accessor :logger
  self.logger = Rails.logger

  USER_AGENT = 'Papernautapp.com by jason.p.morrison@gmail.com'

  def self.get_html(url)
    Loaders.logger.debug("Loader fetching #{url}")

    begin
      body = Curl.get(url) do |http|
        http.headers['User-Agent'] = Loaders::USER_AGENT

        http.follow_location = true
        http.max_redirects = 3
        http.connect_timeout = 5
        http.timeout = 5
      end.body_str

      Nokogiri::HTML.parse(body)
    rescue Curl::Err::TimeoutError => e
      Loaders.logger.error("Loader timed out fetching #{url}")
      nil
    end
  end
end

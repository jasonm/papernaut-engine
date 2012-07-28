require 'json'
require 'curb'

class ZoteroXulrunnerIdentifierService
  def initialize(endpoint_url)
    @endpoint_url = endpoint_url
  end

  def identify(page_url)
    response = send_request(page_url)
    get_identifier(response)
  end

  private

  def send_request(page_url)
    request_json = {
      url: page_url,
      sessionid: "session-for-#{page_url}"
    }.to_json

    Curl::Easy.http_post(endpoint_web_url, request_json) { |curl|
      curl.headers["Content-Type"] = "application/json"
    }.body_str

    # curl -d '{"url":"http://www.neurology.org/content/62/1/60.short","sessionid":"2"}' --header "Content-Type: application/json" localhost:1969/web
  end

  def endpoint_web_url
    "#{@endpoint_url}/web"
  end

  def get_identifier(response)
    items = JSON.parse(response)
    'doi:' + items[0]["DOI"]
  end
end

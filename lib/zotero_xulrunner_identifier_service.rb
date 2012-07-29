require 'json'
require 'curb'

class ZoteroXulrunnerIdentifierService
  def initialize(endpoint_url)
    @endpoint_url = endpoint_url
  end

  def identify(page_url)
    response = request(page_url)
    get_identifier(response)
  end

  private

  def request(page_url)
    request_json = {
      url: page_url,
      sessionid: "session-for-#{page_url}"
    }.to_json

    Curl::Easy.http_post(endpoint_web_url, request_json) { |curl|
      curl.headers["Content-Type"] = "application/json"
    }
  end

  def endpoint_web_url
    "#{@endpoint_url}/web"
  end

  def get_identifier(response)
    if (200..299).include?(response.response_code)
      items = JSON.parse(response.body_str)
      'doi:' + items[0]["DOI"]
    else
      ''
    end
  end
end

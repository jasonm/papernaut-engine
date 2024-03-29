require 'json'
require 'curb'

class ZoteroXulrunnerIdentifierService
  def initialize(endpoint_url, logger = Logger.new(STDOUT))
    @endpoint_url = endpoint_url
    @logger = logger
  end

  def identifiers(page_url)
    @logger.debug("ZoteroXulrunnerIdentifierService: identifying #{page_url}")
    ZoteroXulrunnerIdentificationRequest.new(@endpoint_url, page_url).identifiers
  end
end

class ZoteroXulrunnerIdentificationRequest
  def initialize(endpoint_url, page_url)
    @endpoint_url = endpoint_url
    @page_url = page_url
  end

  def identifiers
    if response.response_code == 200
      [
        identifier_for('DOI'),
        identifier_for('url'),
        extra_identifier_for('PMID'),
        extra_identifier_for('PMCID')
      ].compact
    elsif response.response_code == 300
      # TODO: Handle "300 Multiple Choices", see:
      # * commit 4bf5ef007516244
      # * commit bf206cb4383f4a40
      # * branch handle_300
      []
    else
      []
    end
  end

  private

  def response
    @response ||= begin
      Curl::Easy.http_post(url, body) do |curl|
        curl.headers["Content-Type"] = "application/json"
      end
    end
  end

  def url
    "#{@endpoint_url}/web"
  end

  def body
    { url: url_to_resolve, sessionid: url_to_resolve }.to_json
  end

  def success?
    [200, 300].include?(response.response_code)
  end

  def match
    @match ||= JSON.parse(response.body_str)[0] || {}
  end

  def identifier_for(kind)
    if match.has_key?(kind)
      Identifier.new(body: "#{kind.upcase}:#{match[kind]}")
    end
  end

  def extra_identifier_for(kind)
    if match.has_key?("extra")
      match["extra"].split("\n").each do |line|
        if line =~ /^#{kind}: (.*)$/
          return Identifier.new(body: "#{kind}:#{$1}")
        end
      end

      nil
    end
  end

  # TODO: extract config vars somewhere
  def url_to_resolve
    @url_to_resolve ||= begin
      Curl.get(@page_url) do |http|
        # http.headers['User-Agent'] = USER_AGENT
        http.follow_location = true
        http.max_redirects = 3
        http.connect_timeout = 5
        http.timeout = 5
      end.last_effective_url
    rescue
      @page_url
    end
  end
end

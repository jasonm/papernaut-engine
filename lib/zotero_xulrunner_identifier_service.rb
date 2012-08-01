require 'json'
require 'curb'

class ZoteroXulrunnerIdentifierService
  def initialize(endpoint_url)
    @endpoint_url = endpoint_url
  end

  def identifiers(page_url)
    ZoteroXulrunnerIdentificationRequest.new(@endpoint_url, page_url).identifiers
  end
end

class ZoteroXulrunnerIdentificationRequest
  def initialize(endpoint_url, page_url)
    @endpoint_url = endpoint_url
    @page_url = page_url
  end

  def identifiers
    if success?
      [
        identifier_for('DOI'),
        identifier_for('ISSN'),
        identifier_for('url'),
        extra_identifier_for('PMID'),
        extra_identifier_for('PMCID')
      ].compact
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
    { url: @page_url, sessionid: @page_url }.to_json
  end

  def success?
    (200..299).include?(response.response_code)
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
end
